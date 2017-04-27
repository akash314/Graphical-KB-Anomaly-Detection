IMPORT HPCCFinal;
IMPORT STD;

RevRecords := HPCCFinal.File_WikiProcessed2;

/* Join on Dates to fetch records for specific dates */
//JoinDateRec := JOIN(AllDates, RevRecords, LEFT.dt = RIGHT.dt);
JoinDateRec := RevRecords;
GrForm := RECORD
	STRING8 Dt := JoinDateRec.Dt;
	STRING8 User := JoinDateRec.User;
	DECIMAL10 NoOfUpdate := COUNT(GROUP);
END;
GrTable := TABLE(JoinDateRec, GrForm, Dt, User);

GrFormSum := RECORD
	STRING8 Dt := GrTable.Dt;
	DECIMAL10 TotalUpdates := SUM(GROUP, GrTable.NoOfUpdate);
END;
GrTable2 := TABLE(GrTable, GrFormSum, Dt);
JoinDateRec2 := JOIN(GrTable2, GrTable, LEFT.dt = RIGHT.dt);
Output(JoinDateRec2);

OutF2Rec := RECORD
	STRING8 Dt;
	DECIMAL10 TotUpdates;
	DECIMAL10_5 F2;
	DECIMAL10_5 NormedF2;
END;

OutF2Rec calculateF2(JoinDateRec2 l, OutF2Rec r) := TRANSFORM 
  SELF.Dt := l.Dt; 
	SELF.TotUpdates:=l.TotalUpdates;
  SELF.F2:= r.F2 + (l.NoOfUpdate*l.NoOfUpdate); 
	SELF.NormedF2:=0;
END; 

F2DS := AGGREGATE(JoinDateRec2, OutF2Rec, calculateF2(LEFT, RIGHT), LEFT.Dt);

OutF2Rec NormalizeF2(OutF2Rec l) := TRANSFORM 
  SELF.Dt := l.Dt; 
	SELF.TotUpdates:=l.TotUpdates;
	SELF.F2:= l.F2; 
  SELF.NormedF2:= l.F2/POWER(l.TotUpdates,2.0); 
END; 
NormedF2DS:=PROJECT(F2DS, NormalizeF2(LEFT));

OUTPUT(NormedF2DS,, '~thor::contri_based_f2.txt', overwrite);