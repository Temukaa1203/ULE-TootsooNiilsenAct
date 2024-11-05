codeunit 90320 "SM_13 Localisation Management"
{

    trigger OnRun()
    begin
        MESSAGE(Amount2Text('', 100000.0));
    end;

    var
        Text000: Label 'Тэг';
        Text001: Label 'мянга;мянга;мянга,сая;сая;сая,тэрбум;тэрбум;тэрбум,их наяд;их наяд;их наяд';
        Text002: Label '*** *** ***';
        Text003: Label 'мянга';
        Text004: Label 'мянган';
        MonthName01: Label 'January';
        MonthName02: Label 'February';
        MonthName03: Label 'March';
        MonthName04: Label 'April';
        MonthName05: Label 'May';
        MonthName06: Label 'June';
        MonthName07: Label 'July';
        MonthName08: Label 'August';
        MonthName09: Label 'September';
        MonthName10: Label 'October';
        MonthName11: Label 'November';
        MonthName12: Label 'December';
        ShouldBeLaterErr: Label '%1 should be later than %2.';
        HundredsTxt: Label 'нэг зуун,хоёр зуун,гурван зуун,дөрвөн зуун,таван зуун,зургаан зуун,долоон зуун,найман зуун,есөн зуун';
        TeensTxt: Label 'арван,арван нэгэн,арван хоёр,арван гурван,арван дөрвөн,арван таван,арван зургаан,арван долоон,арван найман,арван есөн';
        DozensTxt: Label 'хорин,гучин,дөчин,тавин,жаран,далан,наян,ерэн';
        OneTxt: Label 'нэгэн,нэгэн,нэгэн';
        TwoTxt: Label 'хоёр,хоёр';
        DigitsTxt: Label 'гурван,дөрвөн,таван,зургаан,долоон,найман,есөн';
        YearsTxt: Label ' years ';
        MonthsTxt: Label ' months ';
        DaysTxt: Label ' days';
        NoDataTxt: Label ' no data ';
        UnitName1Txt: Label 'төгрөг';
        UnitName2Txt: Label 'төгрөг';
        UnitName5Txt: Label 'төгрөг';
        CentName1Txt: Label 'мөнгө';
        CentName2Txt: Label 'мөнгө';
        CentName5Txt: Label 'мөнгө';
        Text013: Label 'НЭГЭН';
        Text1000: Label 'Нэгэн';
        Text1001: Label 'Нэг';

    procedure Amount2Text(CurrencyCode: Code[10]; Amount: Decimal) AmountText: Text
    var
        Currency: Record "Currency";
        DecSym: Decimal;
        DecSymFactor: Decimal;
        DecSymFormat: Text;
        DecSymsText: Text;
        DecSymFactorText: Text;
        InvoiceRoundingType: Text;
        AmountTextTemp: Text[30];
        NeedMPostfix: Boolean;
        NeedNPostfix: Boolean;
        "Unit Kind": Option Male,Female;
        "Hundred Kind": Option Male,Female;
        "Unit Name 1": Text;
        "Unit Name 2": Text;
        "Unit Name 5": Text;
        "Hundred Name 1": Text;
        "Hundred Name 2": Text;
        "Hundred Name 5": Text;
    begin

        //--- Enkh-Erdene
        AmountTextTemp := FORMAT(ROUND(Amount, 1));
        IF Amount > 999 THEN BEGIN
            IF STRLEN(AmountTextTemp) > 3 THEN BEGIN
                AmountTextTemp := COPYSTR(AmountTextTemp, STRLEN(AmountTextTemp) - 2, 3);
                IF AmountTextTemp = '000' THEN
                    NeedMPostfix := TRUE
                ELSE
                    NeedMPostfix := FALSE;
            END;
        END;
        //--- Enkh-Erdene

        Currency.INIT;
        InvoiceRoundingType := SetRoundingPrecision(Currency);
        IF CurrencyCode = '' THEN BEGIN

            "Unit Kind" := "Unit Kind"::Male;
            "Unit Name 1" := UnitName1Txt;
            "Unit Name 2" := UnitName2Txt;
            "Unit Name 5" := UnitName5Txt;
            "Hundred Kind" := "Hundred Kind"::Female;
            "Hundred Name 1" := CentName1Txt;
            "Hundred Name 2" := CentName2Txt;
            "Hundred Name 5" := CentName5Txt;

        END ELSE
            Currency.GET(CurrencyCode);

        IF "Hundred Name 1" = '' THEN
            DecSymFormat := '/'
        ELSE
            DecSymFormat := '';

        DecSymFactor := ROUND(1 / Currency."Invoice Rounding Precision", 1, '<');
        DecSymFactorText := FORMAT(DecSymFactor, 0, '<Integer>');
        DecSym :=
          ROUND(
            (ROUND(Amount, Currency."Invoice Rounding Precision", InvoiceRoundingType) - ROUND(Amount, 1, '<')) *
            DecSymFactor, 1, '<');
        DecSymsText := FORMAT(DecSym, 0, '<Integer>');
        IF STRLEN(DecSymFactorText) > STRLEN(DecSymsText) THEN
            DecSymsText := PADSTR('', STRLEN(DecSymFactorText) - STRLEN(DecSymsText) - 1, '0') + DecSymsText;
        IF DecSymFormat = '/' THEN
            AmountText :=
              Integer2Text(ROUND(Amount, Currency."Invoice Rounding Precision", InvoiceRoundingType),
                "Unit Kind", '', '', '')
        ELSE
            AmountText :=
              Integer2Text(ROUND(Amount, Currency."Invoice Rounding Precision", InvoiceRoundingType),
                "Unit Kind", "Unit Name 1", "Unit Name 2", "Unit Name 5");
        IF DecSymFormat = '/' THEN BEGIN
            IF STRLEN(DELCHR(AmountText, '=', ' ')) > 0 THEN
                AmountText := AmountText + ' ';
            AmountText := AmountText +
              DecSymsText + '/' + DecSymFactorText + ' ' + "Unit Name 2";
        END ELSE BEGIN
            IF STRLEN(DELCHR(AmountText, '=', ' ')) > 0 THEN
                AmountText := AmountText + ' ';
            AmountText := AmountText + DecSymsText + ' ';
            CASE TRUE OF
                (DecSym = 0):
                    AmountText := AmountText + "Hundred Name 5";
                (DecSym > 4) AND (DecSym < 21):
                    AmountText := AmountText + "Hundred Name 5";
                ((DecSym MOD 10) = 1):
                    AmountText := AmountText + "Hundred Name 1";
                ((DecSym MOD 10) > 1) AND ((DecSym MOD 10) < 5):
                    AmountText := AmountText + "Hundred Name 2";
                ELSE
                    AmountText := AmountText + "Hundred Name 5";
            END;
        END;


        //--- Enkh-Erdene
        IF NeedMPostfix THEN
            AmountText := InsertVariableValue(AmountText, Text003, Text004);
        //--- Enkh-Erdene

    end;

    procedure Amount2Text2(CurrencyCode: Code[10]; Amount: Decimal; var WholeAmountText: Text; var HundredAmount: Decimal)
    var
        Currency: Record "Currency";
        DecSymFactor: Decimal;
        InvoiceRoundingType: Text;
        AmountTextTemp: Text[30];
        NeedMPostfix: Boolean;
        NeedNPostfix: Boolean;
        "Unit Kind": Option Male,Female;
        "Hundred Kind": Option Male,Female;
    begin

        //--- Enkh-Erdene
        AmountTextTemp := FORMAT(ROUND(Amount, 1));
        IF Amount > 999 THEN BEGIN
            IF STRLEN(AmountTextTemp) > 3 THEN BEGIN
                AmountTextTemp := COPYSTR(AmountTextTemp, STRLEN(AmountTextTemp) - 2, 3);
                IF AmountTextTemp = '000' THEN
                    NeedMPostfix := TRUE
                ELSE
                    NeedMPostfix := FALSE;
            END;
        END;
        //--- Enkh-Erdene


        "Unit Kind" := "Unit Kind"::Male;
        "Hundred Kind" := "Hundred Kind"::Female;

        Currency.INIT;
        InvoiceRoundingType := SetRoundingPrecision(Currency);
        IF CurrencyCode = '' THEN
            "Unit Kind" := "Unit Kind"::Male
        ELSE
            Currency.GET(CurrencyCode);

        DecSymFactor := ROUND(1 / Currency."Invoice Rounding Precision", 1, '<');
        HundredAmount :=
          ROUND(
            (ROUND(Amount, Currency."Invoice Rounding Precision", InvoiceRoundingType) - ROUND(Amount, 1, '<')) * DecSymFactor, 1, '<');
        WholeAmountText :=
          Integer2Text(ROUND(Amount, Currency."Invoice Rounding Precision", InvoiceRoundingType),
            "Unit Kind", '', '', '');



        //--- Enkh-Erdene
        IF NeedMPostfix THEN
            WholeAmountText := InsertVariableValue(WholeAmountText, Text003, Text004);
        //--- Enkh-Erdene
    end;

    procedure Integer2Text(IntegerValue: Decimal; IntegerGender: Option Femine,Men,Neutral; IntegerNameONE: Text; IntegerNameTWO: Text; IntegerNameFIVE: Text) IntegerText: Text
    var
        DigInInteger: Code[250];
        IndDigInInteger: Integer;
        IndTriad: Integer;
        DigInTriad: array[3] of Integer;
        IndDigInTriad: Integer;
        TriadName: Text;
        Phrase: Text;
        Gender: Integer;
        HasTriad: Boolean;
        AmountTextTemp: Text[30];
        NeedMPostfix: Boolean;
        NeedNPostfix: Boolean;
        TempText_: Text[1024];
    begin

        //--- Enkh-Erdene
        AmountTextTemp := FORMAT(ROUND(IntegerValue, 1));
        IF IntegerValue > 999 THEN BEGIN
            IF STRLEN(AmountTextTemp) > 3 THEN BEGIN
                AmountTextTemp := COPYSTR(AmountTextTemp, STRLEN(AmountTextTemp) - 2, 3);
                IF AmountTextTemp = '000' THEN
                    NeedMPostfix := TRUE
                ELSE
                    NeedMPostfix := FALSE;
            END;
        END;
        //--- Enkh-Erdene

        IF ROUND(IntegerValue, 1, '<') = 0 THEN BEGIN
            IntegerText := Text000;
            HasTriad := FALSE;
        END ELSE BEGIN
            IntegerText := '';
            TriadName := Text001;
            DigInInteger := FORMAT(IntegerValue, 0, '<Integer>');
            IndTriad := (STRLEN(DigInInteger) + 2) DIV 3;
            IF IndTriad > (STRLEN(TriadName) - STRLEN(DELCHR(TriadName, '=', ',')) + 2) THEN BEGIN
                IntegerText := Text002;
                EXIT;
            END;
            IndDigInInteger := 0;
            IndDigInTriad := (3 - (STRLEN(DigInInteger) MOD 3)) MOD 3;
            IF IndDigInTriad > 0 THEN BEGIN
                DigInTriad[1] := 0;
                IF IndDigInTriad > 1 THEN
                    DigInTriad[2] := 0;
            END;
            REPEAT
                REPEAT
                    IndDigInInteger := IndDigInInteger + 1;
                    IndDigInTriad := IndDigInTriad + 1;
                    IF NOT EVALUATE(DigInTriad[IndDigInTriad], COPYSTR(DigInInteger, IndDigInInteger, 1)) THEN
                        DigInTriad[IndDigInTriad] := 0;
                UNTIL IndDigInTriad = 3;
                IndTriad := IndTriad - 1;
                IndDigInTriad := 0;
                CASE IndTriad OF
                    0:
                        Gender := IntegerGender;
                    1:
                        Gender := IntegerGender::Femine;
                    ELSE
                        Gender := IntegerGender::Men;
                END;
                IF IndTriad = 0 THEN
                    HasTriad :=
                      Triad2Text(DigInTriad[1], DigInTriad[2], DigInTriad[3],
                        IntegerText, Gender, IntegerNameONE, IntegerNameTWO, IntegerNameFIVE)
                ELSE BEGIN
                    Phrase := CONVERTSTR(SELECTSTR(IndTriad, TriadName), ';', ',');
                    HasTriad :=
                      Triad2Text(DigInTriad[1], DigInTriad[2], DigInTriad[3],
                        IntegerText, Gender, SELECTSTR(1, Phrase), SELECTSTR(2, Phrase), SELECTSTR(3, Phrase));
                END;
            UNTIL IndDigInInteger = STRLEN(DigInInteger);
        END;
        IF NOT HasTriad THEN
            IntegerText := IntegerText + ' ' + IntegerNameFIVE;

        //--- Enkh-Erdene
        IF NeedMPostfix THEN
            IntegerText := InsertVariableValue(IntegerText, Text003, Text004);
        TempText_ := UPPERCASE(COPYSTR(IntegerText, 1, 5));
        IF TempText_ = Text013 THEN BEGIN
            IntegerText := Text1001 + COPYSTR(IntegerText, 6, STRLEN(IntegerText) - 5);
        END;
        //--- Enkh-Erdene
    end;

    procedure Date2Text(DateValue: Date) DateText: Text
    begin
        IF DateValue = 0D THEN
            EXIT('');
        IF GLOBALLANGUAGE <> 1049 THEN BEGIN
            DateText := FORMAT(DateValue, 0, 4);
            EXIT;
        END;
        DateText := FORMAT(DateValue, 0, '<Day,2> ') + Month2Text(DateValue) + FORMAT(DateValue, 0, ' <Year4>');
    end;

    local procedure Triad2Text(C1: Integer; C2: Integer; C3: Integer; var TargetText: Text; TriadGender: Option Femine,Men,Neutral; TriadNameONE: Text; TriadNameTWO: Text; TriadNameFIVE: Text): Boolean
    var
        TriadWords: Text;
        SymbSkip: Text[1];
        NameSelect: Integer;
    begin
        IF (C1 + C2 + C3) = 0 THEN
            EXIT(FALSE);

        IF C1 > 0 THEN BEGIN
            TriadWords := SELECTSTR(C1, HundredsTxt);
            SymbSkip := ' ';
            NameSelect := 3;
        END ELSE BEGIN
            TriadWords := '';
            SymbSkip := '';
        END;
        IF C2 = 1 THEN BEGIN
            TriadWords := TriadWords + SymbSkip + SELECTSTR(C3 + 1, TeensTxt);
            NameSelect := 3;
        END ELSE BEGIN
            IF C2 > 0 THEN BEGIN
                TriadWords := TriadWords + SymbSkip + SELECTSTR(C2 - 1, DozensTxt);
                SymbSkip := ' ';
                NameSelect := 3;
            END;
            CASE TRUE OF
                (C3 = 1):
                    BEGIN
                        TriadWords := TriadWords + SymbSkip + SELECTSTR(TriadGender + 1, OneTxt);
                        NameSelect := 1;
                    END;
                (C3 = 2):
                    BEGIN
                        IF TriadGender = TriadGender::Neutral THEN
                            NameSelect := TriadGender::Men
                        ELSE
                            NameSelect := TriadGender;
                        TriadWords := TriadWords + SymbSkip + SELECTSTR(NameSelect + 1, TwoTxt);
                        NameSelect := 2;
                    END;
                (C3 > 0):
                    BEGIN
                        TriadWords := TriadWords + SymbSkip + SELECTSTR(C3 - 2, DigitsTxt);
                        IF C3 < 5 THEN
                            NameSelect := 2
                        ELSE
                            NameSelect := 3;
                    END;
            END;
        END;
        IF STRLEN(DELCHR(TargetText, '=', ' ')) = 0 THEN BEGIN
            TriadWords := Triad2UpperCase(TriadWords);
            SymbSkip := '';
        END ELSE
            SymbSkip := ' ';
        CASE NameSelect OF
            1:
                TriadWords := TriadWords + ' ' + TriadNameONE;
            2:
                TriadWords := TriadWords + ' ' + TriadNameTWO;
            ELSE
                TriadWords := TriadWords + ' ' + TriadNameFIVE;
        END;
        TargetText := TargetText + SymbSkip + TriadWords;
        EXIT(TRUE);
    end;

    local procedure Triad2UpperCase(TriadWords: Text): Text
    var
        LowerCaseChars: Text;
        UpperCaseChars: Text;
        FirstSymb: Text[1];
        PosSymb: Integer;
    begin
        LowerCaseChars := 'abcdefghijklmnopqrstuvwxyzабвгдеёжзийклмнопрстуфхцчшщьыъэюяөү';
        UpperCaseChars := 'ABCDEFGHIJKLMNOPQRSTUVWXYZАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЬЫЪЭЮЯӨҮ';
        FirstSymb := COPYSTR(TriadWords, 1, 1);
        PosSymb := STRPOS(LowerCaseChars, FirstSymb);
        IF PosSymb > 0 THEN
            EXIT(FORMAT(UpperCaseChars[PosSymb]) + COPYSTR(TriadWords, 2));

        EXIT(UPPERCASE(COPYSTR(TriadWords, 1, 1)) + COPYSTR(TriadWords, 2));
    end;

    procedure DigitalPartCode(SourceCode: Code[20]) Result: Code[20]
    var
        Index: Integer;
        Symbol: Code[1];
    begin
        Index := STRLEN(SourceCode);
        WHILE Index > 0 DO BEGIN
            Symbol := COPYSTR(SourceCode, Index, 1);
            IF STRPOS('0123456789', Symbol) = 0 THEN BEGIN
                Index := Index - 1;
                IF Index > 0 THEN
                    SourceCode := COPYSTR(SourceCode, 1, Index)
                ELSE
                    SourceCode := '';
            END ELSE
                Index := 0;
        END;
        Index := STRLEN(SourceCode);
        Result := '';
        WHILE Index > 0 DO BEGIN
            Symbol := COPYSTR(SourceCode, Index, 1);
            IF STRPOS('0123456789', Symbol) = 0 THEN
                Index := 0
            ELSE
                Result := Symbol + Result;
            Index := Index - 1;
        END;
        IF Result = '' THEN
            Result := SourceCode;
    end;

    procedure GetPeriodDate(Date1: Date; Date2: Date; Type: Integer): Text
    var
        Delta: Integer;
        DeltaDuration: Duration;
    begin
        IF (Date1 <> 0D) AND (Date2 <> 0D) THEN BEGIN
            DeltaDuration := Date2 - Date1;
            Delta := DeltaDuration;
            CASE Type OF
                0:
                    EXIT(FORMAT(ROUND(Delta / 360, 1, '<')) + GetPeriodText(1) +
                      FORMAT(ROUND(Delta / 30 - ROUND(Delta / 360, 1, '<') * 12, 1, '<')) + GetPeriodText(2) +
                      FORMAT(ROUND(Delta - ROUND(Delta / 360, 1, '<') * 360 - ROUND(Delta / 30 - ROUND(Delta / 360, 1, '<') * 12, 1, '<') * 30)) +
                      GetPeriodText(3));
                1:
                    EXIT(FORMAT(ROUND(Delta / 360, 0.01, '=')) + GetPeriodText(1));
                2:
                    EXIT(FORMAT(ROUND(Delta / 30, 1, '=')) + GetPeriodText(2));
                3:
                    EXIT(FORMAT(ROUND(Delta, 1, '=')) + GetPeriodText(3));
            END;
        END ELSE
            EXIT(NoDataTxt);
    end;

    procedure GetPeriodText(Type: Integer): Text
    begin
        CASE Type OF
            1:
                EXIT(YearsTxt);
            2:
                EXIT(MonthsTxt);
            3:
                EXIT(DaysTxt);
        END;
    end;

    procedure Month2Text(Date: Date) DateText: Text
    begin
        DateText := LOWERCASE(FORMAT(Date, 0, '<Month Text>'));
        IF GLOBALLANGUAGE <> 1049 THEN
            EXIT;

        IF STRLEN(DateText) > 1 THEN
            CASE COPYSTR(DateText, STRLEN(DateText), 1) OF
                'т':
                    DateText := DateText + 'а';
                'ь', 'й':
                    DateText := COPYSTR(DateText, 1, STRLEN(DateText) - 1) + 'я';
            END;
    end;

    procedure GetMonthName(MonthsDate: Date; Genitive: Boolean) Name: Text
    var
        MonthNo: Integer;
    begin
        IF NOT Genitive THEN
            Name := FORMAT(MonthsDate, 0, '<Month Text>')
        ELSE BEGIN
            MonthNo := DATE2DMY(MonthsDate, 2);
            CASE MonthNo OF
                1:
                    Name := MonthName01;
                2:
                    Name := MonthName02;
                3:
                    Name := MonthName03;
                4:
                    Name := MonthName04;
                5:
                    Name := MonthName05;
                6:
                    Name := MonthName06;
                7:
                    Name := MonthName07;
                8:
                    Name := MonthName08;
                9:
                    Name := MonthName09;
                10:
                    Name := MonthName10;
                11:
                    Name := MonthName11;
                12:
                    Name := MonthName12;
            END;
        END;
    end;

    procedure CheckPeriodDates(StartDate: Date; EndDate: Date): Integer
    begin
        IF (StartDate <> 0D) AND (EndDate <> 0D) THEN BEGIN
            IF StartDate > EndDate THEN
                ERROR(ShouldBeLaterErr, EndDate, StartDate);
            EXIT(EndDate - StartDate + 1);
        END;
    end;

    procedure DateMustBeLater(FieldCaption: Text; Date2: Date)
    begin
        ERROR(ShouldBeLaterErr, FieldCaption, Date2);
    end;

    local procedure SetRoundingPrecision(var Currency: Record Currency): Text
    begin
        Currency.InitRoundingPrecision;
        IF NOT (Currency."Invoice Rounding Precision" IN [0.1, 0.01]) THEN
            Currency."Invoice Rounding Precision" := 0.01;
        CASE Currency."Invoice Rounding Type" OF
            Currency."Invoice Rounding Type"::Up:
                EXIT('>');
            Currency."Invoice Rounding Type"::Down:
                EXIT('<');
            ELSE
                EXIT('=');
        END;
    end;

    procedure FormatDate(DateToFormat: Date): Text
    begin
        EXIT(FORMAT(DateToFormat, 0, '<Day,2>.<Month,2>.<Year4>'));
    end;

    procedure InsertVariableValue(Formula_: Text[1024]; VariableName_: Text[1024]; VariableValue_: Text[1024]) Result: Text[1024]
    var
        Pos: Integer;
        DecimalLocalTemp: Decimal;
    begin
        IF STRPOS(Formula_, VariableValue_) = 0 THEN BEGIN
            IF STRPOS(Formula_, VariableName_) <> 0 THEN BEGIN
                Pos := STRPOS(Formula_, VariableName_);
                Formula_ := DELSTR(Formula_, Pos, STRLEN(VariableName_));
                Formula_ := INSSTR(Formula_, VariableValue_, Pos);
            END;
        END;
        EXIT(Formula_);
    end;
}

