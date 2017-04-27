IMPORT HPCCFinal;
IMPORT STD;

DtForm := RECORD
	STRING8 dt;
END;
RevRecords := HPCCFinal.File_WikiProcessed2;
/* Join on Dates to fetch records for specific dates */
//JoinDateRec := JOIN(AllDates, RevRecords, LEFT.dt = RIGHT.dt);
JoinDateRec := RevRecords;
GrForm := RECORD
	STRING8 Dt := JoinDateRec.Dt;
	STRING8 User := JoinDateRec.User;
	DECIMAL5 NoOfUpdate := COUNT(GROUP);
	DECIMAL5 NoOfContri := 1
END;
GrTable := TABLE(JoinDateRec, GrForm, Dt, User);
GrTable;

GrForm Xform(GrForm L,GrForm R) := TRANSFORM
	SELF.NoOfContri := L.NoOfContri + R.NoOfContri;
	SELF.Dt := L.Dt;
	SELF.User := '-';
	SELF.noofupdate := R.noofupdate+L.noofupdate;
END;

roll := ROLLUP(GrTable,LEFT.Dt=RIGHT.Dt,Xform(LEFT,RIGHT));

OutF0Rec := RECORD
	STRING8 Dt;
	DECIMAL10 TotUpdates;
	DECIMAL10_5 F0;
	DECIMAL10_5 NormedF0;
END;

OutF0Rec NormalizeF0(roll l) := TRANSFORM 
  SELF.Dt := l.Dt; 
	SELF.TotUpdates:=l.noofupdate;
	SELF.F0:= l.NoOfContri; 
  SELF.NormedF0:= l.NoOfContri/l.noofupdate; 
END; 
NormedF0DS:=PROJECT(roll, NormalizeF0(LEFT));

OUTPUT(NormedF0DS,, '~thor::contri_based_f0.txt', overwrite);
