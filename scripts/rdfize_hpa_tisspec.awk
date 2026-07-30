### usage: gawk -f rdfize_hpa_tisspec.awk -v col=COL hpa_[tissue,cell]_[uberon,caloha,cl].tsv proteinatlas.tsv

BEGIN {
    FS = "\t"
    if(!col) {
        print "ERROR: Specify column number.\n -v col=19 for tissues\n -v col=23 for cells" > "/dev/stderr"
        exit 1
    }
    print "@prefix ensembl: <http://identifiers.org/ensembl/> ."
    print "@prefix hpao: <http://med2rdf.org/hpa/ontology#> ."
    print ""
}

FNR==NR {
    tis2id[$2] = $1
    next
}

FNR>=2 {
    ### use $19 for tissues, $23 for cells
    split(gensub("\"", "", "g", $col), tissues, ";")
    print "ensembl:" $3 " a hpao:HPA_target_gene ."
    for(t in tissues) {
        split(tissues[t], tissue, ":")
        if(!(tissue[1] in tis2id)) {
            print "ERROR: No HPAO mapping found for \"" tissue[1] "\" (line " FNR ")" > "/dev/stderr"
            exit 1
        }
        print "ensembl:" $3 " hpao:isPositivelySpecificTo hpao:" tis2id[tissue[1]] " ."
    }
}

