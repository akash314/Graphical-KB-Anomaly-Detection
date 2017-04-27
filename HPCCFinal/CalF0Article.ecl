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
	STRING8 ArticleId := JoinDateRec.ArticleId;
	DECIMAL5 NoOfUpdate := COUNT(GROUP);
	DECIMAL5 NoOfArticle := 1
END;
GrTable := TABLE(JoinDateRec, GrForm, Dt, ArticleId);
GrTable;

GrForm Xform(GrForm L,GrForm R) := TRANSFORM
	SELF.NoOfArticle := L.NoOfArticle + R.NoOfArticle;
	SELF.Dt := L.Dt;
	SELF.ArticleId := '-';
	SELF.noofupdate := R.noofupdate+L.noofupdate;
END;
//r := ROLLUP(GrTable,TRANSFORM(LEFT),Dt,ArticleId);
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
	SELF.F0:= l.NoOfArticle; 
  SELF.NormedF0:= l.NoOfArticle/l.noofupdate; 
END; 
NormedF0DS:=PROJECT(roll, NormalizeF0(LEFT));

OUTPUT(NormedF0DS,, '~thor::article_based_f0.txt', overwrite);