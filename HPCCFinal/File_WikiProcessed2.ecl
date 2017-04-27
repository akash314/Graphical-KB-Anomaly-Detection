IMPORT HPCCFinal;
EXPORT File_WikiProcessed2 :=
DATASET('~thor::processed_rev_recs.txt',
       {HPCCFinal.Layout_Processed_Wiki,
        UNSIGNED8 fpos {virtual(fileposition)}},THOR);
        
