# Dashboard Shiny — Mercado de Trabalho Rural/Urbano (PNAD Contínua)

App R/Shiny com gráfico de linha interativo (plotly): seleção de variável (agrupada por categoria), UF e período via slider de anos.

## Estrutura

```
dashboard_shiny/
├── app.R               # ui + server
└── data/
    ├── data_wide.csv   # UF, Ano, 165 indicadores (uma coluna por indicador)
    └── labels.csv      # variavel, grupo, label
```

## Por que exportar via Shinylive

Este app é Shiny "de verdade", mas você quer hospedar de forma estática no GitHub Pages (sem servidor R rodando). O pacote **shinylive** resolve isso: compila o app para rodar inteiramente no navegador via WebAssembly (webR), gerando uma pasta só com HTML/JS/WASM que pode ser publicada em qualquer hospedagem estática.

Importante: o ambiente onde eu processei seus dados não tem acesso a CRAN/instalação de R, então não consegui testar o `app.R` rodando de fato — revisei a sintaxe manualmente (parênteses/chaves balanceados, nomes de colunas confirmados contra `data_wide.csv`), mas peço que você rode o passo 1 abaixo e me avise se aparecer algum erro.

## Passo a passo (rodar no seu computador, onde você já tem R)

### 1. Testar localmente antes de exportar

```r
install.packages(c("shiny", "plotly"))
shiny::runApp("dashboard_shiny")
```

Confirme que a variável, a UF e o slider de anos respondem corretamente e que o hover mostra o valor.

### 2. Instalar o shinylive e exportar

```r
install.packages("shinylive")
shinylive::export(appdir = "dashboard_shiny", destdir = "docs")
```

Isso cria a pasta `docs/` com os arquivos estáticos prontos para o GitHub Pages (o nome `docs` já é o padrão aceito pelo Pages, mas você pode usar outro destino).

### 3. Testar a versão exportada localmente

```r
shinylive::run_app_dir("docs")
# ou: python3 -m http.server 8000 --directory docs
```

O primeiro carregamento é mais lento que a versão HTML/JS pura (o navegador baixa o runtime do R via WebAssembly, ~tens of MB), mas depois disso roda inteiramente no cliente.

### 4. Publicar no GitHub Pages

1. Suba a pasta `docs/` (gerada no passo 2) para a raiz do repositório.
2. No GitHub: **Settings → Pages**.
3. Em "Source", selecione a branch (ex.: `main`) e a pasta `/docs`.
4. Salve. A URL fica em `https://<usuario>.github.io/<repositorio>/`.

## Atualizando os dados

Sempre que `Base_Dashboard.csv` mudar, regenere `data/data_wide.csv` e `data/labels.csv` (mesmo pivot: UF + Ano nas linhas, um indicador por coluna) e repita o passo 2 (export) e 4 (publicar).

## Alternativa mais simples (já pronta, sem R)

Se o tempo de carregamento do Shinylive incomodar, a pasta `../dashboard/` (HTML + JavaScript + Plotly via CDN) já tem o mesmo gráfico funcionando, carrega instantaneamente e não depende de R — é só publicar `dashboard/` direto no Pages. Posso adicionar lá o slider de anos também, se preferir essa rota.
