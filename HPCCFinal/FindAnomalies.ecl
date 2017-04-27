IMPORT HPCCFinal;
//RevRecords := HPCCFinal.ExportFiles.File_CDWE[1..10];
RevRecords := HPCCFinal.ExportFiles.File_ADWE[1..10];

EInit := SUM(RevRecords,RevRecords.NormedEntropy)/10;
//EInit;
Thresh := 0.05;
OutAnomalyRec := RECORD
	STRING8 Dt;
	DECIMAL10_5 Entropy;
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
	SELF.Entropy := l.NormedEntropy;
END;

//EntropyWithE := PROJECT(HPCCFinal.ExportFiles.File_CDWE, prepInitRecords(LEFT, COUNTER));
EntropyWithE := PROJECT(HPCCFinal.ExportFiles.File_ADWE, prepInitRecords(LEFT, COUNTER));
EntropyWithE;
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
	
	DECIMAL10_5 relDev := ABS(r.Entropy - l.E)/l.E;
	DECIMAL10_5 tempE := l.E + (0.3*(r.Entropy - l.E));
	SELF.Dt := r.Dt;
	SELF.Entropy := r.Entropy;
	SELF.RelDevn := relDev;
	SELF.E := IF(C<2, EInit, IF(relDev>Thresh,l.E,tempE));
  SELF.Anomaly:= IF(relDev > Thresh, TRUE, FALSE); 	

END;
EntropyDS := ITERATE(EntropyWithE, calculateAnomaly(LEFT, RIGHT, COUNTER));
//EntropyDS := AGGREGATE(EntropyWithE, OutAnomalyRec, calculateAnomaly(LEFT, RIGHT), LEFT.Dt);

//OUTPUT(EntropyDS,, '~thor::Anomaly_Contri_H.txt', overwrite);
OUTPUT(EntropyDS,, '~thor::Anomaly_Article_H.txt', overwrite);

