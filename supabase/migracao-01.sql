-- ============================================================
-- Caixa — migração 01
--
-- Para quem já rodou o schema antes desta correção.
-- O histórico de valor dos investimentos precisa da mesma marca
-- de exclusão que as outras tabelas, senão a sincronização quebra
-- ao filtrar por ela.
--
-- Rode no SQL Editor. Pode rodar mais de uma vez.
-- ============================================================

alter table public.ativo_historico
  add column if not exists excluido_em timestamptz;
