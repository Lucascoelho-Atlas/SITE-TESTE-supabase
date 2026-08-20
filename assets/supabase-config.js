// Configuracao do Supabase para o site Atlas English.
// Preencha SUPABASE_URL e SUPABASE_ANON_KEY com os valores do seu projeto:
// Supabase Dashboard -> Project Settings -> API.
// A anon/publishable key e publica por design (protegida pelas RLS policies do banco).

const SUPABASE_URL = 'https://lvmvybpfdhucriviyzej.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_GatQe1S2mCi5fY0apED66Q_Mf62a3dV';

const supabaseClient = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
