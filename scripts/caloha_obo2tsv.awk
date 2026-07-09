### Extract "name" and "synonym" lines from a CALOHA OBO file and convert to TSV.
###
### usage: gawk -f caloha_obo2tsv.awk caloha.obo > caloha_labels.tsv
###
### output columns: id  name|synonym  label

BEGIN {
    OFS = "\t"
}

/^id:/ {
    id = gensub(/^CALOHA:/, "", "g", $2)
}

/^name:/ {
    print id, "name", gensub(/^name: /, "", "g", $0)
}

/^synonym:/ {
    print id, "synonym", gensub(/(^synonym: )|"|( RELATED \[\])/, "", "g", $0)
}
