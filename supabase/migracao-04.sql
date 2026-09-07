-- Marca do banco na conta, para o app mostrar nome, cor e ícone certos
-- quando o extrato ou a fatura é importado.
alter table public.contas add column if not exists banco text not null default '';

-- Cartão de crédito: dia em que a fatura fecha e dia em que ela vence.
alter table public.contas add column if not exists fechamento smallint not null default 0;
alter table public.contas add column if not exists vencimento smallint not null default 0;
