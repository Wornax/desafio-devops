import http from 'http';
import PG from 'pg';

const port = Number(process.env.PORT) || 5000;
const dbConfig = {
  host: process.env.DB_HOST || 'db',
  port: Number(process.env.DB_PORT) || 5432,
  database: process.env.DB_NAME || 'app_db',
  user: process.env.DB_USER || 'admin',
  password: process.env.DB_PASSWORD || 'securepassword',
};

const client = new PG.Client(dbConfig);

async function startServer() {
  try {
    await client.connect();
    console.log('Conectado ao banco de dados com sucesso');
  } catch (err) {
    console.error('Erro ao conectar ao banco de dados:', err.stack);
    process.exit(1);
  }

  http
    .createServer(async (req, res) => {
      console.log(`Requisição: ${req.url}`);

      if (req.url === '/api') {
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('Access-Control-Allow-Origin', '*');

        let result;
        let databaseConnected = true;

        try {
          result = (await client.query('SELECT * FROM users LIMIT 1')).rows[0];
        } catch (error) {
          console.error('Erro na consulta ao banco:', error.stack);
          databaseConnected = false;
        }

        const data = {
          database: databaseConnected,
          userAdmin: result?.role === 'admin',
        };

        res.writeHead(200);
        res.end(JSON.stringify(data));
      } else {
        res.writeHead(404);
        res.end(JSON.stringify({ error: 'Rota não encontrada' }));
      }
    })
    .listen(port, () => {
      console.log(`Servidor rodando na porta ${port}`);
    });
}

startServer();