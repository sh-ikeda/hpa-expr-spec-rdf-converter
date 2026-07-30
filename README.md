# hpa-expr-spec-rdf-converter

Human Protein Atlas (HPA) が公開している `proteinatlas.tsv` をもとに、遺伝子の組織特異的発現（tissue specificity）・細胞特異的発現（cell specificity）データを RDF (Turtle) 化するための簡易スクリプト集です。

## 必要環境

- `gawk`（GNU awk）
  - スクリプト内で `gensub()` を使用しているため、GNU awk が必須です（POSIX awk / mawk 等では動作しません）。

## ディレクトリ構成

```
.
├── input/    入力データ（HPA の組織・細胞名と CALOHA/Uberon の ID とのマッピングなど）
├── scripts/  変換用 awk スクリプト
├── output/   生成した RDF の出力先
└── old/      過去に生成した RDF ファイル等（git 管理外）
```

## 入力データ

### proteinatlas.tsv（別途取得が必要）

HPA の公式サイトからダウンロードする TSV ファイルです。サイズが大きいためこのリポジトリには含まれていません。以下からダウンロードしてください。

- https://www.proteinatlas.org/about/download

`proteinatlas.tsv` の中には、組織ごと・細胞種ごとの発現値を `組織名: 値;組織名: 値;...` の形式で保持している列があります。変換スクリプトはこの列から組織名／細胞種名の部分だけを取り出して使用します。列番号は HPA のバージョンによって変わる可能性があるため、実行前に以下のようなコマンドでヘッダーを確認し、該当列の番号を確認してください。

```sh
head -1 proteinatlas.tsv | tr '\t' '\n' | cat -n
```

### input/ 以下のマッピングファイル

- `hpa_tissue_caloha.tsv`
  - `proteinatlas.tsv` 中の組織名と、CALOHA オントロジーの ID (`TS-XXXX`) との対応表。変換スクリプトが実際に参照するファイル。
  - 列構成: `[HPAでの表記に対するID] [HPAでの表記] [CALOHA ID] [CALOHAでのラベル]`
- `hpa_cell_cl.tsv`
  - `proteinatlas.tsv` 中の細胞種名と、Cell Ontology の ID との対応表。変換スクリプトが実際に参照するファイル。
  - HPA で独自の分類をしており、Cell Ontology に対応づかないものも多い。
  - 列構成: `[HPAでの表記に対するID] [HPAでの表記] [Cell Ontology ID] [Cell Ontologyでのラベル]`
- `hpa_tissue_uberon.tsv`
  - 組織名と Uberon ID (`UBERON_XXXXXXX`) との対応表。現在のスクリプトでは未使用（Uberon 版を出力したい場合の参考データ）。
- `hpa_tissue.tsv`, `hpa_cell.tsv`
  - `proteinatlas.tsv` に登場する組織名・細胞種名の一覧。
- `caloha_hpa_tissues.tsv`, `caloha_hpa_cells.tsv`
  - CALOHA 側のラベル情報。上記マッピングファイルを作成する際に参照した元データです。

## 使い方

`scripts/rdfize_hpa_tisspec.awk` に、マッピングファイルと `proteinatlas.tsv` をこの順に渡して実行します。`-v col=` で `proteinatlas.tsv` 側のどの列を発現データとして使うかを指定します。

```sh
# 組織特異的発現（tissue specificity）
gawk -f scripts/rdfize_hpa_tisspec.awk -v col=19 \
    input/hpa_tissue_caloha.tsv proteinatlas.tsv > output/hpa_tissue_specificity.ttl

# 細胞特異的発現（cell specificity）
gawk -f scripts/rdfize_hpa_tisspec.awk -v col=23 \
    input/hpa_cell_cl.tsv proteinatlas.tsv > output/hpa_cell_specificity.ttl
```

- `col=19`: 組織特異的発現を変換する場合
- `col=23`: 細胞特異的発現を変換する場合

（列番号は `proteinatlas.tsv` のバージョンに依存するため、変わっている場合は適宜変更してください。）

## 出力

各遺伝子について、以下のような Turtle が出力されます。

```turtle
@prefix ensembl: <http://identifiers.org/ensembl/> .
@prefix hpao: <http://med2rdf.org/hpa/ontology#> .

ensembl:ENSG00000000005 a hpao:HPA_target_gene .
ensembl:ENSG00000000005 hpao:isPositivelySpecificTo hpao:HPAT_000001 .
```

- `hpao:HPA_target_gene`: HPA によって発現量が測定された遺伝子であることを示すクラス。`proteinatlas.tsv` に含まれるすべての遺伝子に付与されます。
- `hpao:isPositivelySpecificTo`: その遺伝子が特異的に発現している組織／細胞種を示すプロパティ。該当する組織・細胞がない遺伝子には出力されません。

出力は主語ごとにまとめられていない素朴な Turtle（トリプルの羅列）です。整形したい場合は `riot`（Apache Jena）や `rapper`（Raptor RDF Syntax Library）などのツールで整形してください。
