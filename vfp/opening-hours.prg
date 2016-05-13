LOCAL lcResults
gdWednesday = DATETIME(2016,5,11,12,22)
gdThurday = DATETIME(2016,5,12,12,22)
gdFridayMorning = DATETIME(2016,5,13,8,0,0)
CLEAR
CLOSE DATABASES all
setup()

TEXT TO lcResults NOSHOW TEXTMERGE
Wednesday is open? <<TRANSFORM(isOpenOn(gdWednesday))>>
Thursday is open? <<TRANSFORM(isOpenOn(gdThurday))>>
Next opening date after Wednesday is <<nextOpeningDate(gdWednesday)>>
Next opening date after Friday is <<nextOpeningDate(gdFridayMorning)>>
ENDTEXT
MESSAGEBOX(lcResults,0,'Results')

FUNCTION isOpenOn(tdDateTime)
	RETURN INDEXSEEK(DowNormalized(tdDateTime),.t.,'openhours','dow') ;
			and BETWEEN(HOUR(tdDateTime)*100+MINUTE(tdDateTime), openhours.opentime, openhours.closetime)
ENDFUNC 

FUNCTION nextOpeningDate(tdDateTime)
	LOCAL ldNextOpen, lnDow, lnOpenTime, ldTmp
	SELECT top 1 dayofweek, opentime from openhours ;
		where dayofweek > DowNormalized(tdDateTime) ;
		order by dayofweek ;
		into array laDow
	IF _tally = 0
		SELECT openhours
		LOCATE 
		IF FOUND('openhours')
			SCATTER fields dayofweek, opentime to laDow
			laDow(1) = laDow(1) + 7
		ELSE
			RELEASE laDow
			THROW "No open days. The shop is closed forever."
		ENDIF 
	ENDIF 
	lnDow = laDow(1)
	lnOpenTime =laDow(2)
	RELEASE laDow
	ldTmp = DATE(YEAR(tdDateTime),MONTH(tdDateTime),DAY(tdDateTime)) + lnDow - DowNormalized(tdDateTime)
	ldNextOpen = DATETIME(YEAR(ldTmp),MONTH(ldTmp),DAY(ldTmp),lnOpenTime/100,lnOpenTime%100)
	RETURN TTOC(ldNextOpen,3) + 'Z'
ENDFUNC 

FUNCTION DowNormalized(tdDate) && Set Monday to first day of week
	RETURN DOW(tdDate,2)
ENDFUNC 


* Read from a file if need be or setup the default test.
FUNCTION setup()
	* CSV file, dow (Monday being 1), start time (military), end time (military)
	* 1,800,1600
	* 3,800,1600
	* 5,800,1600
	LOCAL lcFile
	lcFile = 'openhours.csv'
	CREATE CURSOR openhours ( ;
		dayofweek i, ;
		opentime i, ;
		closetime i)
	IF FILE(lcFile)
		LOCAL lcContents, lcLine
		lcContents = FILETOSTR(lcFile)
		ALINES(laLines,lcContents)
		FOR EACH lcLine in laLines
			IF ALINES(laVal,lcLine,1,',') = 3
				INSERT into openhours values(VAL(laVal(1)),VAL(laVal(2)),VAL(laVal(3)))
			ENDIF 
		ENDFOR
		RELEASE laLines
		RELEASE laVal
	ELSE 
		INSERT into openhours values(1,800,1600)
		INSERT into openhours values(3,800,1600)
		INSERT into openhours values(5,800,1600)
	ENDIF 
	INDEX on dayofweek tag dow unique
ENDFUNC 
