IMPORT HPCCFinal;
RevRecords := HPCCFinal.ExportFiles.File_F2_Article[1..10];
//RevRecords := HPCCFinal.ExportFiles.File_F2_Contri[1..10];

EInit := SUM(RevRecords,RevRecords.NormedF2)/10;
//EInit;
Thresh := 0.5;
OutAnomalyRec := RECORD
	STRING8 Dt;
	DECIMAL10_5 F2;
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
	SELF.F2 := l.NormedF2;
END;

F2WithE := PROJECT(HPCCFinal.ExportFiles.File_F2_Article, prepInitRecords(LEFT, COUNTER));
//F2WithE := PROJECT(HPCCFinal.ExportFiles.File_F2_Contri, prepInitRecords(LEFT, COUNTER));
F2WithE;

OutAnomalyRec calculateAnomaly(OutAnomalyRec l, OutAnomalyRec r, Integer C) := TRANSFORM 
	
	DECIMAL10_5 relDev := ABS(r.F2 - l.E)/l.E;
	DECIMAL10_5 tempE := l.E + (0.3*(r.F2 - l.E));
	SELF.Dt := r.Dt;
	SELF.F2 := r.F2;
	SELF.RelDevn := relDev;
	SELF.E := IF(C<2, EInit, IF(relDev>Thresh,l.E,tempE));
  SELF.Anomaly:= IF(relDev > Thresh, TRUE, FALSE); 	

END;
F2DS := ITERATE(F2WithE, calculateAnomaly(LEFT, RIGHT, COUNTER));

OUTPUT(F2DS,, '~thor::Anomaly_Article_F2.txt', overwrite);
//OUTPUT(F2DS,, '~thor::Anomaly_Contri_F2.txt', overwrite);

