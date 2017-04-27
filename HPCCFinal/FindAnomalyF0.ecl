IMPORT HPCCFinal;
RevRecords := HPCCFinal.ExportFiles.File_F0_Article[1..10];
//RevRecords := HPCCFinal.ExportFiles.File_F0_Contri[1..10];

EInit := SUM(RevRecords,RevRecords.NormedF0)/10;
//EInit;
Thresh := 0.3;
OutAnomalyRec := RECORD
	STRING8 Dt;
	DECIMAL10_5 F0;
	DECIMAL10_5 E;
	DECIMAL10_5 RelDevn;
	BOOLEAN Anomaly;
END;

OutAnomalyRec prepInitRecords(RevRecords l, INTEGER1 C) := TRANSFORM 
	//SELF.E := if(C<2, EInit, 0);
	SELF.E := EInit;
  SELF.Anomaly := FALSE; 
	SELF.Dt:=l.Dt;
	SELF.RelDevn:=0;
	SELF.F0 := l.NormedF0;
END;

//F0WithE := PROJECT(HPCCFinal.ExportFiles.File_F0_Article, prepInitRecords(LEFT, COUNTER));
F0WithE := PROJECT(HPCCFinal.ExportFiles.File_F0_Contri, prepInitRecords(LEFT, COUNTER));
F0WithE;
/*
OutAnomalyRec calculateAnomaly(OutAnomalyRec l, OutAnomalyRec r) := TRANSFORM 
	//temp := r.E + (0.3*(l.Entropy - r.E))
	temp := if(TRUE, 8, 7);
	SELF.Dt := l.Dt; 
	SELF.E := 9.0;
  SELF.Anomaly:= IF(temp > Thresh, TRUE, FALSE); 
	SELF.Entropy := l.Entropy;
	SELF := R;
END; */


OutAnomalyRec calculateAnomaly(OutAnomalyRec l, OutAnomalyRec r, Integer C) := TRANSFORM 
	
	DECIMAL10_5 relDev := ABS(r.F0 - l.E)/l.E;
	DECIMAL10_5 tempE := l.E + (0.3*(r.F0 - l.E));
	SELF.Dt := r.Dt;
	SELF.F0 := r.F0;
	SELF.RelDevn := relDev;
	SELF.E := IF(C<2, EInit, IF(relDev>Thresh,l.E,tempE));
  SELF.Anomaly:= IF(relDev > Thresh, TRUE, FALSE); 	

END;
F0DS := ITERATE(F0WithE, calculateAnomaly(LEFT, RIGHT, COUNTER));
//EntropyDS := AGGREGATE(EntropyWithE, OutAnomalyRec, calculateAnomaly(LEFT, RIGHT), LEFT.Dt);

OUTPUT(F0DS,, '~thor::Anomaly_Article_F0.txt', overwrite);
//OUTPUT(F0DS,, '~thor::Anomaly_Contri_F0.txt', overwrite);


