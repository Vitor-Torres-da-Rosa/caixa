-- ============================================================
-- Caixa — migração 03 (versão 3.5.0)
--
-- Rode este arquivo inteiro no SQL Editor do Supabase, em cima
-- do banco que você já tem. Pode rodar mais de uma vez.
--
-- O que ele faz:
--   1. vários números de telefone por cliente
--   2. pagamento mínimo, juros por atraso e data de quitação
--      nas parcelas
--   3. o pagamento passa a apontar para a parcela que ele quita,
--      o que permite pagar em partes
-- ============================================================

-- 1. Vários números por cliente
alter table public.clientes
  add column if not exists telefones jsonb not null default '[]';

-- 2. Mínimo, juros de atraso e quitação
alter table public.parcelas
  add column if not exists minimo       bigint       not null default 0,
  add column if not exists juros_atraso numeric(5,2) not null default 0,
  add column if not exists quitada_em   date;

-- 3. O pagamento aponta para a parcela
alter table public.pagamentos
  add column if not exists parcela_id text references public.parcelas (id) on delete set null;

create index if not exists idx_pagamentos_parcela on public.pagamentos (user_id, parcela_id);
