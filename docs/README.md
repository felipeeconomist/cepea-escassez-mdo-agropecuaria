# Dashboard — Mercado de Trabalho Rural/Urbano (PNAD Contínua)

Página estática (HTML + JavaScript + [Plotly.js](https://plotly.com/javascript/) via CDN) com gráfico de linha interativo: seleção de variável, UF e intervalo de anos, com tooltip ao passar o mouse.

## Estrutura

```
dashboard/
├── index.html          # página e lógica do dashboard
└── data/
    ├── data.json       # série histórica (UF, Ano, 165 indicadores) — formato wide
    └── labels.json      # rótulo e categoria de cada indicador
```

Os dados foram gerados a partir de `Base_Dashboard.csv` (formato longo) e convertidos para um formato wide compacto, reduzindo o tamanho de ~8,4 MB para ~2,2 MB.

## Como atualizar os dados

Sempre que `Base_Dashboard.csv` for atualizado, regenere `data.json` e `labels.json` com o mesmo pivot (UF + Ano nas linhas, um indicador por coluna) e substitua os arquivos em `data/`.

## Publicar no GitHub Pages

1. Crie um repositório no GitHub (pode ser público ou privado, desde que o plano permita Pages).
2. Suba o conteúdo desta pasta `dashboard/` para a raiz do repositório (ou para uma subpasta `/docs`).
3. No repositório, vá em **Settings → Pages**.
4. Em "Source", selecione a branch (ex.: `main`) e a pasta (`/root` ou `/docs`, conforme onde você colocou os arquivos).
5. Salve. O GitHub gera uma URL no formato `https://<usuario>.github.io/<repositorio>/` em alguns minutos.

## Testar localmente antes de publicar

Como o navegador bloqueia `fetch()` em arquivos abertos diretamente (`file://`), sirva a pasta com um servidor local simples, por exemplo:

```bash
cd dashboard
python3 -m http.server 8000
```

Depois acesse `http://localhost:8000` no navegador.
