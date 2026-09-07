-- Marca do banco na conta, para o app mostrar nome, cor e ícone certos
-- quando o extrato ou a fatura é importado.
alter table public.contas add column if not exists banco text not null default '';
