IMPORT HPCCFinal;
EXPORT File_Wiki :=
DATASET('main2002part.txt',HPCCFinal.Layout_Wiki,CSV(heading(0),separator(' '),quote('')));