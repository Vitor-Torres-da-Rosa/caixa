-- ============================================================
-- Caixa — migração 02 (versão 3.4.0)
--
-- Rode este arquivo inteiro no SQL Editor do Supabase, em cima
-- do banco que você já tem. Pode rodar mais de uma vez.
--
-- O que ele faz:
--   1. campos novos no perfil (inflação, meta de patrimônio,
--      contas ligadas, reserva, tipos de registro)
--   2. WhatsApp no cliente e tipo no registro
--   3. conta ligada à meta
--   4. a tabela nova de parcelas, com RLS ligada
-- ============================================================

-- 1. Perfil
alter table public.perfis
  add column if not exists inflacao_anual      numeric(5,2) not null default 4,
  add column if not exists retirada_anual      numeric(5,2) not null default 4,
  add column if not exists meta_patrimonio     bigint       not null default 0,
  add column if not exists conta_aposentadoria text,
  add column if not exists reserva_ligada      boolean      not null default true,
  add column if not exists reserva_conta       text,
  add column if not exists reserva_manual      bigint       not null default 0,
  add column if not exists tipos_registro      text[]       not null default '{}';

-- 2. Cliente e registro
alter table public.clientes
  add column if not exists whatsapp boolean not null default true;

alter table public.servicos
  add column if not exists tipo text not null default 'Serviço';

-- 3. Meta ligada a uma conta
alter table public.metas
  add column if not exists conta_id text references public.contas (id) on delete set null;

-- 4. Parcelas combinadas com o cliente
create table if not exists public.parcelas (
  id            text        primary key,
  user_id       uuid        not null default auth.uid() references auth.users (id) on delete cascade,
  cliente_id    text        not null references public.clientes (id) on delete cascade,
  servico_id    text        references public.servicos (id) on delete set null,
  pagamento_id  text        references public.pagamentos (id) on delete set null,
  numero        smallint    not null check (numero >= 1),
  total         smallint    not null check (total >= 1),
  valor         bigint      not null check (valor > 0),
  vencimento    date        not null,
  criado_em     timestamptz not null default now(),
  atualizado_em timestamptz not null default now(),
  excluido_em   timestamptz
);

create index if not exists idx_parcelas_user on public.parcelas (user_id, cliente_id, vencimento);

-- Row Level Security: sem isso, a chave pública leria os dados de todo mundo.
alter table public.parcelas enable row level security;
alter table public.parcelas force row level security;
drop policy if exists dono_parcelas on public.parcelas;
create policy dono_parcelas on public.parcelas
  for all to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

drop trigger if exists tg_atualizacao on public.parcelas;
create trigger tg_atualizacao before update on public.parcelas
  for each row execute function public.marcar_atualizacao();

-- Permissões: anon fica de fora, como nas outras tabelas.
revoke all on public.parcelas from anon;
grant select, insert, update, delete on public.parcelas to authenticated;
