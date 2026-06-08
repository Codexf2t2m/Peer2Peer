-- ==========================================
-- USERS & PROFILES
-- ==========================================

CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  full_name TEXT,
  email TEXT NOT NULL UNIQUE,
  phone TEXT,
  location TEXT,
  lending_mode TEXT CHECK (lending_mode IN ('direct', 'community', 'both')),
  available_lending_amount DECIMAL(15,2) DEFAULT 0,
  borrowing_limit DECIMAL(15,2) DEFAULT 0,
  reputation_score TEXT DEFAULT 'NEW',
  -- Onboarding state machine:
  -- pending_verification → email_verified → bank_connected → kyc_uploaded → credit_assessed → active
  onboarding_step TEXT DEFAULT 'pending_verification'
    CHECK (onboarding_step IN (
      'pending_verification',
      'email_verified',
      'bank_connected',
      'kyc_uploaded',
      'credit_assessed',
      'active'
    )),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.credit_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES public.profiles(id) ON DELETE CASCADE,
  credit_score INTEGER,
  risk_band TEXT,
  approved_borrowing_limit DECIMAL(15,2),
  model_version TEXT,
  last_assessed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==========================================
-- OPEN BANKING & TRANSACTIONS
-- ==========================================

CREATE TABLE IF NOT EXISTS public.bank_connections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  provider TEXT NOT NULL,
  bank_name TEXT,
  account_id_external TEXT,
  connection_status TEXT CHECK (connection_status IN ('active', 'inactive', 'revoked')),
  connected_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_synced_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.bank_webhook_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_type TEXT NOT NULL,
  provider_event_id TEXT,
  bank_connection_id UUID NOT NULL REFERENCES public.bank_connections(id) ON DELETE CASCADE,
  payload JSONB,
  received_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  processed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.bank_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  bank_connection_id UUID NOT NULL REFERENCES public.bank_connections(id) ON DELETE CASCADE,
  external_transaction_id TEXT,
  type TEXT,
  amount DECIMAL(15,2),
  currency TEXT DEFAULT 'BWP',
  transaction_date TIMESTAMP WITH TIME ZONE,
  description TEXT,
  status TEXT DEFAULT 'COMPLETED',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==========================================
-- RECONCILIATION
-- ==========================================

CREATE TABLE IF NOT EXISTS public.reconciliation_runs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  run_started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  run_completed_at TIMESTAMP WITH TIME ZONE,
  status TEXT CHECK (status IN ('running', 'completed', 'failed')),
  total_matched INTEGER DEFAULT 0,
  total_missing INTEGER DEFAULT 0,
  total_mismatched INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.reconciliation_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reconciliation_run_id UUID NOT NULL REFERENCES public.reconciliation_runs(id) ON DELETE CASCADE,
  internal_transaction_id UUID,
  bank_transaction_id UUID REFERENCES public.bank_transactions(id),
  match_status TEXT CHECK (match_status IN ('matched', 'missing', 'mismatched')),
  amount_diff DECIMAL(15,2),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==========================================
-- BADGES & REPUTATION
-- ==========================================

CREATE TABLE IF NOT EXISTS public.badges (
  code TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  requirement_description TEXT,
  icon_name TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.user_badges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  badge_code TEXT NOT NULL REFERENCES public.badges(code) ON DELETE CASCADE,
  earned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_featured BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==========================================
-- LOANS
-- ==========================================

CREATE TABLE IF NOT EXISTS public.loan_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  borrower_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  request_type TEXT CHECK (request_type IN ('community', 'direct')),
  target_lender_id UUID REFERENCES public.profiles(id),
  amount_requested DECIMAL(15,2) NOT NULL,
  interest_rate FLOAT NOT NULL,
  duration_days INTEGER NOT NULL,
  purpose TEXT,
  status TEXT CHECK (status IN ('draft', 'active', 'funded', 'repaying', 'completed', 'cancelled')),
  funded_amount DECIMAL(15,2) DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.active_loans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  loan_request_id UUID NOT NULL UNIQUE REFERENCES public.loan_requests(id) ON DELETE CASCADE,
  borrower_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  principal DECIMAL(15,2) NOT NULL,
  total_repayment_amount DECIMAL(15,2) NOT NULL,
  due_date DATE NOT NULL,
  status TEXT CHECK (status IN ('active', 'default', 'completed')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.loan_contributions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  loan_request_id UUID NOT NULL REFERENCES public.loan_requests(id) ON DELETE CASCADE,
  lender_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  amount_contributed DECIMAL(15,2) NOT NULL,
  expected_return DECIMAL(15,2) NOT NULL,
  platform_cut DECIMAL(15,2) NOT NULL,
  status TEXT CHECK (status IN ('pending', 'funded', 'repaying', 'completed')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==========================================
-- MANDATES
-- ==========================================

CREATE TABLE IF NOT EXISTS public.mandates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  active_loan_id UUID NOT NULL UNIQUE REFERENCES public.active_loans(id) ON DELETE CASCADE,
  borrower_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  mandate_reference TEXT UNIQUE,
  signing_timestamp TIMESTAMP WITH TIME ZONE,
  signing_ip TEXT,
  device_fingerprint TEXT,
  mandate_document_url TEXT,
  status TEXT CHECK (status IN ('pending', 'signed', 'active', 'cancelled')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==========================================
-- LEDGER & TRANSACTIONS
-- ==========================================

CREATE TABLE IF NOT EXISTS public.transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  loan_request_id UUID REFERENCES public.loan_requests(id),
  active_loan_id UUID REFERENCES public.active_loans(id),
  type TEXT CHECK (type IN ('funding', 'repayment', 'interest', 'fee', 'withdrawal', 'deposit')),
  gross_amount DECIMAL(15,2) NOT NULL,
  fee_amount DECIMAL(15,2) DEFAULT 0,
  net_amount DECIMAL(15,2) NOT NULL,
  status TEXT CHECK (status IN ('pending', 'completed', 'failed')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==========================================
-- BILLING
-- ==========================================

CREATE TABLE IF NOT EXISTS public.platform_billing (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lender_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  billing_period TEXT NOT NULL,
  total_loans_funded DECIMAL(15,2) DEFAULT 0,
  total_interest_earned DECIMAL(15,2) DEFAULT 0,
  platform_cut_amount DECIMAL(15,2) DEFAULT 0,
  p2_fees_collected DECIMAL(15,2) DEFAULT 0,
  total_billed DECIMAL(15,2) DEFAULT 0,
  status TEXT CHECK (status IN ('pending', 'billed', 'paid')),
  billed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==========================================
-- SYSTEM & NOTIFICATIONS
-- ==========================================

CREATE TABLE IF NOT EXISTS public.system_jobs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  type TEXT NOT NULL,
  schedule TEXT,
  status TEXT CHECK (status IN ('active', 'inactive', 'running')),
  last_run_at TIMESTAMP WITH TIME ZONE,
  next_run_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  type TEXT NOT NULL,
  message TEXT NOT NULL,
  is_read BOOLEAN DEFAULT FALSE,
  metadata JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.complaints (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  against_user_id UUID REFERENCES public.profiles(id),
  type TEXT NOT NULL,
  status TEXT CHECK (status IN ('open', 'investigating', 'resolved', 'closed')),
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==========================================
-- KYC DOCUMENTS
-- ==========================================

CREATE TABLE IF NOT EXISTS public.kyc_documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  document_type TEXT NOT NULL,
  document_url TEXT NOT NULL,
  status TEXT CHECK (status IN ('pending', 'approved', 'rejected')),
  review_notes TEXT,
  reviewed_by UUID REFERENCES public.profiles(id),
  reviewed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==========================================
-- RLS POLICIES
-- ==========================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.credit_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bank_connections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bank_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.loan_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.active_loans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.loan_contributions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mandates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.kyc_documents ENABLE ROW LEVEL SECURITY;

-- Users can view their own profile
CREATE POLICY "Users can view their own profile" ON public.profiles
  FOR SELECT USING (auth.uid()::text = id::text);

-- Users can update their own profile
CREATE POLICY "Users can update their own profile" ON public.profiles
  FOR UPDATE USING (auth.uid()::text = id::text);

-- Users can view their own credit profile
CREATE POLICY "Users can view own credit profile" ON public.credit_profiles
  FOR SELECT USING (auth.uid()::text = user_id::text);

-- Users can view their own bank connections
CREATE POLICY "Users can view own bank connections" ON public.bank_connections
  FOR SELECT USING (auth.uid()::text = user_id::text);

-- Users can view their own bank transactions
CREATE POLICY "Users can view own bank transactions" ON public.bank_transactions
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.bank_connections bc
      WHERE bc.id = bank_connection_id
      AND auth.uid()::text = bc.user_id::text
    )
  );

-- Users can view loans they created or contributed to
CREATE POLICY "Users can view relevant loans" ON public.loan_requests
  FOR SELECT USING (
    auth.uid()::text = borrower_id::text
    OR EXISTS (
      SELECT 1 FROM public.loan_contributions lc
      WHERE lc.loan_request_id = id
      AND auth.uid()::text = lc.lender_id::text
    )
  );

-- Users can view their own contributions
CREATE POLICY "Users can view own contributions" ON public.loan_contributions
  FOR SELECT USING (auth.uid()::text = lender_id::text);

-- Users can view their own transactions
CREATE POLICY "Users can view own transactions" ON public.transactions
  FOR SELECT USING (auth.uid()::text = user_id::text);

-- Users can view their own notifications
CREATE POLICY "Users can view own notifications" ON public.notifications
  FOR SELECT USING (auth.uid()::text = user_id::text);

-- Users can view their own KYC documents
CREATE POLICY "Users can view own KYC documents" ON public.kyc_documents
  FOR SELECT USING (auth.uid()::text = user_id::text);

-- Users can view mandates they signed
CREATE POLICY "Borrowers can view their mandates" ON public.mandates
  FOR SELECT USING (auth.uid()::text = borrower_id::text);

-- ==========================================
-- INSERT RLS POLICIES
-- ==========================================

-- The trigger (below) inserts the profile row as the service role, so no
-- client-side INSERT policy is needed for profiles. The policy is added here
-- as a safety net for direct API clients.
CREATE POLICY "Users can insert own profile" ON public.profiles
  FOR INSERT WITH CHECK (auth.uid()::text = id::text);

-- Borrowers can create loan requests on their own behalf
CREATE POLICY "Borrowers can insert loan requests" ON public.loan_requests
  FOR INSERT WITH CHECK (auth.uid()::text = borrower_id::text);

-- Borrowers can update their own loan requests (e.g. cancel)
CREATE POLICY "Borrowers can update own loan requests" ON public.loan_requests
  FOR UPDATE USING (auth.uid()::text = borrower_id::text);

-- Lenders can fund loans by inserting contributions
CREATE POLICY "Lenders can insert contributions" ON public.loan_contributions
  FOR INSERT WITH CHECK (auth.uid()::text = lender_id::text);

-- The system (service role) updates contributions; lenders cannot directly
-- but we allow them to update their own for status transitions
CREATE POLICY "Lenders can update own contributions" ON public.loan_contributions
  FOR UPDATE USING (auth.uid()::text = lender_id::text);

-- Any authenticated user can insert a transaction on their own user_id
CREATE POLICY "Users can insert own transactions" ON public.transactions
  FOR INSERT WITH CHECK (auth.uid()::text = user_id::text);

-- ==========================================
-- COMMUNITY BROWSE POLICY
-- ==========================================

-- Any authenticated user can browse active community loan requests.
-- Sensitive borrower information (email, phone, bank details) is protected
-- because those fields live in other tables governed by their own RLS policies.
-- The loan_requests select above only exposes non-sensitive loan fields;
-- the Flutter client selects only public borrower fields (full_name,
-- reputation_score) via the profiles join.
CREATE POLICY "Authenticated users can browse active community requests"
  ON public.loan_requests
  FOR SELECT
  USING (
    auth.role() = 'authenticated'
    AND status = 'active'
    AND request_type = 'community'
  );

-- ==========================================
-- ATOMIC FUNDING TRANSACTION FUNCTION (RPC)
-- ==========================================

CREATE OR REPLACE FUNCTION public.fund_loan_request(
  p_loan_request_id UUID,
  p_lender_id UUID,
  p_amount DECIMAL(15,2),
  p_expected_return DECIMAL(15,2),
  p_platform_cut DECIMAL(15,2)
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_status TEXT;
  v_amount_requested DECIMAL(15,2);
  v_funded_amount DECIMAL(15,2);
  v_new_funded DECIMAL(15,2);
  v_new_status TEXT;
BEGIN
  -- Lock the row for update to prevent race conditions (double funding)
  SELECT status, amount_requested, funded_amount
  INTO v_status, v_amount_requested, v_funded_amount
  FROM public.loan_requests
  WHERE id = p_loan_request_id
  FOR UPDATE;

  IF v_status IS DISTINCT FROM 'active' THEN
    RAISE EXCEPTION 'Loan request is not active';
  END IF;

  IF v_funded_amount + p_amount > v_amount_requested THEN
    RAISE EXCEPTION 'Contribution exceeds remaining amount requested';
  END IF;

  -- 1. Insert the contribution record
  INSERT INTO public.loan_contributions (
    loan_request_id,
    lender_id,
    amount_contributed,
    expected_return,
    platform_cut,
    status
  )
  VALUES (
    p_loan_request_id,
    p_lender_id,
    p_amount,
    p_expected_return,
    p_platform_cut,
    'funded'
  );

  -- 2. Update the loan request amount and status
  v_new_funded := v_funded_amount + p_amount;
  IF v_new_funded >= v_amount_requested THEN
    v_new_status := 'funded';
  ELSE
    v_new_status := 'active';
  END IF;

  UPDATE public.loan_requests
  SET funded_amount = v_new_funded,
      status = v_new_status,
      updated_at = NOW()
  WHERE id = p_loan_request_id;

  -- 3. Register the funding transaction record
  INSERT INTO public.transactions (
    user_id,
    loan_request_id,
    type,
    gross_amount,
    fee_amount,
    net_amount,
    status
  )
  VALUES (
    p_lender_id,
    p_loan_request_id,
    'funding',
    p_amount,
    p_platform_cut,
    p_amount,
    'completed'
  );
END;
$$;

-- ==========================================
-- AUTH TRIGGER: auto-create profile on sign-up
-- ==========================================

-- Function called by the trigger
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, email, created_at, updated_at)
  VALUES (
    NEW.id,
    NEW.email,
    NOW(),
    NOW()
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

-- Trigger fires after a new row is inserted into auth.users
CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- ==========================================
-- INDEXES
-- ==========================================

CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles(email);
CREATE INDEX IF NOT EXISTS idx_bank_connections_user ON public.bank_connections(user_id);
CREATE INDEX IF NOT EXISTS idx_bank_transactions_connection ON public.bank_transactions(bank_connection_id);
CREATE INDEX IF NOT EXISTS idx_loan_requests_borrower ON public.loan_requests(borrower_id);
CREATE INDEX IF NOT EXISTS idx_loan_requests_status ON public.loan_requests(status);
CREATE INDEX IF NOT EXISTS idx_loan_requests_type ON public.loan_requests(request_type);
CREATE INDEX IF NOT EXISTS idx_active_loans_borrower ON public.active_loans(borrower_id);
CREATE INDEX IF NOT EXISTS idx_loan_contributions_lender ON public.loan_contributions(lender_id);
CREATE INDEX IF NOT EXISTS idx_transactions_user ON public.transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_read ON public.notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_kyc_documents_user ON public.kyc_documents(user_id);
CREATE INDEX IF NOT EXISTS idx_user_badges_user ON public.user_badges(user_id);
CREATE INDEX IF NOT EXISTS idx_bank_connections_status ON public.bank_connections(connection_status);
CREATE INDEX IF NOT EXISTS idx_kyc_documents_status ON public.kyc_documents(status);

-- ==========================================
-- ONBOARDING: MISSING RLS INSERT POLICIES
-- ==========================================

-- Users can insert their own bank connections
CREATE POLICY "Users can insert own bank connections" ON public.bank_connections
  FOR INSERT WITH CHECK (auth.uid()::text = user_id::text);

-- Users can update their own bank connections (e.g. revoke)
CREATE POLICY "Users can update own bank connections" ON public.bank_connections
  FOR UPDATE USING (auth.uid()::text = user_id::text);

-- Users can insert their own KYC documents
CREATE POLICY "Users can insert own KYC documents" ON public.kyc_documents
  FOR INSERT WITH CHECK (auth.uid()::text = user_id::text);

-- Users can update their own onboarding step (guarded by check constraint)
CREATE POLICY "Users can update onboarding step" ON public.profiles
  FOR UPDATE USING (auth.uid()::text = id::text);

-- Users can insert their own notifications (used by onboarding completion flow)
CREATE POLICY "Users can insert own notifications" ON public.notifications
  FOR INSERT WITH CHECK (auth.uid()::text = user_id::text);

-- ==========================================
-- CREDIT PROFILE: INSERT/UPDATE POLICIES
-- ==========================================

ALTER TABLE public.credit_profiles ENABLE ROW LEVEL SECURITY;

-- Service role inserts credit profile; allow via RPC. Direct client insert guarded:
CREATE POLICY "Users can insert own credit profile" ON public.credit_profiles
  FOR INSERT WITH CHECK (auth.uid()::text = user_id::text);

CREATE POLICY "Users can update own credit profile" ON public.credit_profiles
  FOR UPDATE USING (auth.uid()::text = user_id::text);

-- ==========================================
-- RPC: COMPLETE ONBOARDING (atomic credit profile + notification + step update)
-- ==========================================

CREATE OR REPLACE FUNCTION public.complete_credit_assessment(
  p_user_id UUID,
  p_credit_score INTEGER,
  p_risk_band TEXT,
  p_borrowing_limit DECIMAL(15,2),
  p_model_version TEXT DEFAULT '1.0'
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Upsert credit profile
  INSERT INTO public.credit_profiles (
    user_id,
    credit_score,
    risk_band,
    approved_borrowing_limit,
    model_version,
    last_assessed_at
  )
  VALUES (
    p_user_id,
    p_credit_score,
    p_risk_band,
    p_borrowing_limit,
    p_model_version,
    NOW()
  )
  ON CONFLICT (user_id) DO UPDATE
    SET credit_score = EXCLUDED.credit_score,
        risk_band = EXCLUDED.risk_band,
        approved_borrowing_limit = EXCLUDED.approved_borrowing_limit,
        model_version = EXCLUDED.model_version,
        last_assessed_at = NOW(),
        updated_at = NOW();

  -- Update borrowing limit on profile
  UPDATE public.profiles
  SET borrowing_limit = p_borrowing_limit,
      onboarding_step = 'active',
      updated_at = NOW()
  WHERE id = p_user_id;

  -- Send account activated notification
  INSERT INTO public.notifications (user_id, type, message, metadata)
  VALUES (
    p_user_id,
    'account_activated',
    'Your PulaPay account is now active. Your borrowing limit is P' || p_borrowing_limit::TEXT || '.',
    jsonb_build_object('borrowing_limit', p_borrowing_limit, 'risk_band', p_risk_band)
  );
END;
$$;

-- ==========================================
-- RPC: CREATE BANK CONNECTION (returns new connection id)
-- ==========================================

CREATE OR REPLACE FUNCTION public.create_bank_connection(
  p_user_id UUID,
  p_provider TEXT,
  p_bank_name TEXT,
  p_account_id_external TEXT
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_connection_id UUID;
BEGIN
  INSERT INTO public.bank_connections (
    user_id,
    provider,
    bank_name,
    account_id_external,
    connection_status,
    connected_at
  )
  VALUES (
    p_user_id,
    p_provider,
    p_bank_name,
    p_account_id_external,
    'active',
    NOW()
  )
  RETURNING id INTO v_connection_id;

  -- Advance onboarding step if still at email_verified
  UPDATE public.profiles
  SET onboarding_step = CASE
        WHEN onboarding_step = 'email_verified' THEN 'bank_connected'
        ELSE onboarding_step
      END,
      updated_at = NOW()
  WHERE id = p_user_id;

  RETURN v_connection_id;
END;
$$;

