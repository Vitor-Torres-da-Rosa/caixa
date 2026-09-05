// Configuração do servidor.
//
// Enquanto estiver em branco, o Caixa funciona só dentro do aparelho,
// com os dados cifrados no navegador. Preenchendo, ele passa também a
// sincronizar com o Supabase.
//
// Estas duas chaves são públicas por natureza: ficam dentro do app e
// qualquer pessoa consegue lê-las no navegador. Quem protege os dados é
// o Row Level Security configurado no banco, não o sigilo delas.
// A chave service_role NUNCA entra aqui.
//
// Passo a passo em supabase/CONFIGURACAO.md.

window.CAIXA_CONFIG = {
  supabaseUrl: '',
  supabaseAnonKey: ''
};
