unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, XPMan, StdCtrls, Menus;

type
  TMetric = class(TForm)
    Memo: TMemo;
    ButtonExit: TButton;
    xpmnfst1: TXPManifest;
    ButtonOpen: TButton;
    OpenDialog: TOpenDialog;
    ButtonAnalysis: TButton;
    MainMenu: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem: TMenuItem;
    _MetricaChepina: TLabel;
    _Formula: TLabel;
    MetricResult: TEdit;
    _Variables: TLabel;
    ArrayOfVariable: TMemo;
    _P: TLabel;
    Variables_P: TEdit;
    _M: TLabel;
    Variables_M: TEdit;
    _C: TLabel;
    Variables_C: TEdit;
    _T: TLabel;
    Variables_T: TEdit;

    procedure ButtonExitClick(Sender: TObject);
    procedure ButtonOpenClick(Sender: TObject);
    procedure ConvertCode();
    procedure Recognition();
    procedure Recognition_In_For();
    procedure Search_Input_Output();
    procedure Search_Modified();
    procedure Search(Overlap: Integer; LineFromMemo: String; k: Integer; send: Integer);
    procedure Search_Operation();
    procedure ButtonAnalysisClick(Sender: TObject);



  private
    { Private declarations }
  public
    { Public declarations }
  end;
const
  MaxArrayOfEachType = 100;

var
  Metric: TMetric;

  ArrayValue, Array_Not_Found_P, Array_Not_Found_M, Array_Not_Found_C : array [1..MaxArrayOfEachType] of String;
implementation

{$R *.dfm}

procedure TMetric.ButtonExitClick(Sender: TObject);
begin
  Close;
end;

procedure TMetric.ButtonOpenClick(Sender: TObject);
var
  SourceFile : TextFile;
  EnterFile, Line : string;
begin
  if OpenDialog.Execute then
  begin
    EnterFile := OpenDialog.FileName;
    AssignFile(SourceFile, EnterFile);
    Reset(SourceFile);
    while not Eof(SourceFile) do
    begin
      Readln(SourceFile,Line);
      Memo.Lines.Add(Line);
    end;
    CloseFile(SourceFile);
  end
  else
    ShowMessage('                             Error !!!                        ');
  ConvertCode();
end;


//Преобразование кода
procedure TMetric.ConvertCode();
const
  EmptySymbol = '';
  SpaceSymbol = ' ';
  SharpSymbol = '#';
  TabSymbol = #9;
  SlashSymbol = '/';
var
  i, j, NumberOfSpaces : Integer;
  LineFromMemo: String;
begin
  LineFromMemo := EmptySymbol;
  NumberOfSpaces := 0;
  for i := Memo.Lines.Count-1 downto 0 do
  begin
    LineFromMemo := Memo.Lines[i];
    for j:=1 to length(LineFromMemo) do
      if LineFromMemo[j] = SpaceSymbol then inc(NumberOfSpaces);
    if NumberOfSpaces = length(LineFromMemo) then Memo.Lines.Delete(i)
    else
     Memo.Lines[i] := LineFromMemo;
    LineFromMemo := EmptySymbol;
    NumberOfSpaces := 0;
  end;


  LineFromMemo := EmptySymbol;
  i := 0;
  while i <= Memo.Lines.Count-2 do
  begin
    LineFromMemo := Memo.Lines[i];
    if  Pos(SharpSymbol,LineFromMemo) = 1 then
    begin
      Memo.Lines.Delete(i);
      Dec(i);
    end;
    Inc(i);
  end;

  LineFromMemo := EmptySymbol;
  for i := 2 to Memo.Lines.Count-2 do
  begin
    LineFromMemo := Memo.Lines[i];
    j := 1;
    while j <= length(LineFromMemo) do
    begin
      if LineFromMemo[j] = TabSymbol then
      begin
        Delete(LineFromMemo,j,1);
        dec(j);
      end;
      inc(j);
    end;
    Memo.Lines[i] := LineFromMemo;
    LineFromMemo := EmptySymbol;
  end;

  LineFromMemo := EmptySymbol;
  for i := 0 to Memo.Lines.Count-2 do
  begin
    LineFromMemo := Memo.Lines[i];
    for j:=1 to length(LineFromMemo) do
      if (LineFromMemo[j] = SlashSymbol) and (LineFromMemo[j+1] = SlashSymbol) then
        if j = 1 then Memo.Lines.Delete(i)
        else
        begin
          Delete(LineFromMemo,j,length(LineFromMemo)-j+1);
          Memo.Lines[i] := LineFromMemo;
        end;
    LineFromMemo := EmptySymbol;
  end;


end;


procedure TMetric.Recognition();
const
  typeChar = 'char'; typeShort = 'short'; typeInt = 'int';
  typeLong = 'long'; typeFloat = 'float'; typeDouble = 'double';
  typeVoid = 'void'; typeSigned = 'signed'; typeUnsigned = 'unsigned';
  EmptySymbol = ''; SpaceSymbol = ' ';
  SquareBracketRSymbol = '['; SquareBracketLSymbol = ']';
  BraceRSymbol = '{'; BraceLSymbol = '}';
  CommaSymbol = ','; SemicolonSymbol = ';';
  EqualSymbol = '=';
  SymbolOfZero = '0'; SymbolOfUnit = '1'; SymbolOfDeuces = '2'; SymbolOfThee = '3'; SymbolOfFour = '4';
  SymbolOfFive = '5'; SymbolOfSix = '6'; SymbolOfSeven = '7'; SymbolOfEight = '8'; SymbolOfNine = '9';
var
  i, j, k, temporary, count, NumberOfCommas,x,interim, LengthOfTempSymbolString : Integer;
  LineFromMemo, TempTypesString, TempString, TempSymbolsString : String;
begin
  LineFromMemo := EmptySymbol;
  TempTypesString := EmptySymbol;
  TempString := EmptySymbol;
  TempSymbolsString :=  EmptySymbol;
  count := 0;
  NumberOfCommas := 0;
  for i := 1 to Memo.Lines.Count-2 do
  begin
    temporary := 0;
    LineFromMemo := Memo.Lines[i];

    for j:=1 to length(LineFromMemo) do
      if LineFromMemo[j] = SpaceSymbol then break;
    TempTypesString := copy(LineFromMemo,1,j-1);

    if (TempTypesString = typeChar) or (TempTypesString = typeShort) or (TempTypesString = typeInt)  then temporary := 1;
    if (TempTypesString = typeLong) or (TempTypesString = typeFloat) or (TempTypesString = typeDouble)  then temporary := 1;
    if (TempTypesString = typeVoid) or (TempTypesString = typeSigned) or (TempTypesString = typeUnsigned)  then temporary := 1;

    if temporary = 1 then
    begin
      TempString := copy(LineFromMemo,j+1,length(LineFromMemo)-j);
      for x := 1 to length(TempString) do
      begin
        if TempString[x] = CommaSymbol then inc(NumberOfCommas);
        if TempString[x] = BraceRSymbol then break;
      end;
      interim := 0;
      k := 1;

      while interim <= NumberOfCommas do
      begin
        for x := k to length(TempString) do
          if (TempString[x] = CommaSymbol) then break;
        TempSymbolsString := copy(TempString,k,x-k);
        if TempString[x+1] = SpaceSymbol then k := x+2;
        if TempString[x+1] <> SpaceSymbol then k := x+1;
        LengthOfTempSymbolString := 1;
        while LengthOfTempSymbolString <= length(TempSymbolsString) do
        begin
          if (TempSymbolsString[LengthOfTempSymbolString] = SquareBracketRSymbol) or (TempSymbolsString[LengthOfTempSymbolString] = SquareBracketLSymbol) then
          begin
            Delete(TempSymbolsString,LengthOfTempSymbolString,1);
            LengthOfTempSymbolString := LengthOfTempSymbolString-2;
          end;
          if (TempSymbolsString[LengthOfTempSymbolString] = EqualSymbol) or (TempSymbolsString[LengthOfTempSymbolString] = SemicolonSymbol) or (TempSymbolsString[LengthOfTempSymbolString] = SpaceSymbol) then
          begin
            Delete(TempSymbolsString,LengthOfTempSymbolString,1);
            LengthOfTempSymbolString := LengthOfTempSymbolString-2;
          end;
          if (TempSymbolsString[LengthOfTempSymbolString] = SymbolOfZero) or (TempSymbolsString[LengthOfTempSymbolString] = SymbolOfUnit) or (TempSymbolsString[LengthOfTempSymbolString] = SymbolOfDeuces) then
          begin
            Delete(TempSymbolsString,LengthOfTempSymbolString,1);
            LengthOfTempSymbolString := LengthOfTempSymbolString-2;
          end;
          if (TempSymbolsString[LengthOfTempSymbolString] = SymbolOfThee) or (TempSymbolsString[LengthOfTempSymbolString] = SymbolOfFour) then
          begin
            Delete(TempSymbolsString,LengthOfTempSymbolString,1);
            LengthOfTempSymbolString := LengthOfTempSymbolString-2;
          end;
          if (TempSymbolsString[LengthOfTempSymbolString] = SymbolOfFive) or (TempSymbolsString[LengthOfTempSymbolString] = SymbolOfSix) then
          begin
            Delete(TempSymbolsString,LengthOfTempSymbolString,1);
            LengthOfTempSymbolString := LengthOfTempSymbolString-2;
          end;
          if (TempSymbolsString[LengthOfTempSymbolString] = SymbolOfSeven) or (TempSymbolsString[LengthOfTempSymbolString] = SymbolOfEight) or (TempSymbolsString[LengthOfTempSymbolString] = SymbolOfNine) then
          begin
            Delete(TempSymbolsString,LengthOfTempSymbolString,1);
            LengthOfTempSymbolString := LengthOfTempSymbolString-2;
          end;
          if (TempSymbolsString[LengthOfTempSymbolString] = BraceRSymbol) or (TempSymbolsString[LengthOfTempSymbolString] = BraceLSymbol)then
          begin
            Delete(TempSymbolsString,LengthOfTempSymbolString,1);
            LengthOfTempSymbolString := LengthOfTempSymbolString-2;
          end;
          inc(LengthOfTempSymbolString);
        end;

        inc(count);
        ArrayValue[count] := TempSymbolsString;
        inc(interim);
        TempSymbolsString := EmptySymbol;
      end;
    end;
    LineFromMemo := EmptySymbol;
    TempTypesString := EmptySymbol;
    TempString := EmptySymbol;
    NumberOfCommas := 0;
  end;
end;


procedure TMetric.Recognition_In_For();
const
  typeChar = 'char'; typeShort = 'short'; typeInt = 'int';
  typeLong = 'long'; typeFloat = 'float'; typeDouble = 'double';
  typeVoid = 'void'; typeSigned = 'signed'; typeUnsigned = 'unsigned';
  InstructionFor = 'for';
  EmptySymbol = '';
  SpaceSymbol = ' ';
  SemicolonSymbol = ';';
var
  i,  j, k, temporary : Integer;
  LineFromMemo, TempSymbolsString, TypeInFor : String;
  Overlap : Integer;
begin
  LineFromMemo := EmptySymbol;
  TypeInFor := EmptySymbol;
  temporary := 0;
  for i := 1 to Memo.Lines.Count-2 do
  begin
    LineFromMemo := Memo.Lines[i];
    Overlap := Pos(InstructionFor,LineFromMemo);


    if Overlap <> 0 then TempSymbolsString := copy(LineFromMemo,6,length(LineFromMemo)-6);
    if TempSymbolsString <> EmptySymbol then
    begin

      for j := 1 to length(TempSymbolsString) do
        if TempSymbolsString[j] = SemicolonSymbol then break;
      Delete(TempSymbolsString,j-4,length(TempSymbolsString)-j+5);

      for k := 1 to length(TempSymbolsString) do
        if TempSymbolsString[k] = SpaceSymbol then break;
      TypeInFor := copy(TempSymbolsString,1,k-1);   //хранит тип в фор

      if (TypeInFor = typeChar) or (TypeInFor = typeShort) or (TypeInFor = typeInt)  then temporary := k;
      if (TypeInFor = typeLong) or (TypeInFor = typeFloat) or (TypeInFor = typeDouble)  then temporary := k;
      if (TypeInFor = typeVoid) or (TypeInFor = typeSigned) or (TypeInFor = typeUnsigned)  then temporary := k;

      if temporary <> 0 then
      begin
        for k := 1 to length(TempSymbolsString) do
          if TempSymbolsString[k] = SpaceSymbol then break;
        Delete(TempSymbolsString,1,k);
        for k := 1 to MaxArrayOfEachType do
          if ArrayValue[k] = EmptySymbol then break;
        ArrayValue[k] := TempSymbolsString;
      end;
    end;
    temporary := 0;
    TempSymbolsString := EmptySymbol;
    LineFromMemo := EmptySymbol;
    TypeInFor := EmptySymbol;
  end;
end;

//Поиск переменных ввода-вывода (P)
procedure TMetric.Search_Input_Output();
const
  EmptySymbol = '';
  CommaSymbol = ','; CommaAndSpaceSymbols = ', ';
  Printf = 'printf';
  Scanf = 'scanf';
var
  i, j, k, coincidence, PrintOrScanffoverlap, LengthOfMemoLine, count, LocationVariableInP : Integer;
  LineFromMemo, ArrayOfTempVariables : String;
begin
  LineFromMemo := EmptySymbol;
  for j := 1 to MaxArrayOfEachType do
    if ArrayValue[j] = EmptySymbol then break;
  k := j-1;

  for j := 1 to k do
  begin
    ArrayOfTempVariables := ArrayValue[j];

    for i := 1 to Memo.Lines.Count-2 do
    begin
      LineFromMemo := Memo.Lines[i];
      coincidence := Pos(ArrayOfTempVariables,LineFromMemo);

      if coincidence > 0 then
      begin
        PrintOrScanffoverlap := Pos(Printf, LineFromMemo);
        if PrintOrScanffoverlap > 0 then
        begin
          for LengthOfMemoLine := 1 to length(LineFromMemo) do
            if LineFromMemo[LengthOfMemoLine] = CommaSymbol then break;
          Delete(LineFromMemo,1,LengthOfMemoLine);
          count := Pos(ArrayOfTempVariables, LineFromMemo); //местоположение переменной в printf
          if count > 0 then
          begin
            LocationVariableInP := Pos(ArrayOfTempVariables, Variables_P.Text);  //Местоположение переменной в Edit типа P
            if LocationVariableInP = 0 then                      //Если её нет,то заносим
              if Variables_P.Text = EmptySymbol then Variables_P.Text := ArrayOfTempVariables
              else
                Variables_P.Text := Variables_P.Text + CommaAndSpaceSymbols + ArrayOfTempVariables;
          end;
        end;

        PrintOrScanffoverlap := Pos(Scanf, LineFromMemo);
        if PrintOrScanffoverlap > 0 then
        begin
          for LengthOfMemoLine := 1 to length(LineFromMemo) do
            if LineFromMemo[LengthOfMemoLine] = ',' then break;
          Delete(LineFromMemo,1,LengthOfMemoLine);
          count := Pos(ArrayOfTempVariables, LineFromMemo);
          if count > 0 then
          begin
            LocationVariableInP := Pos(ArrayOfTempVariables, Variables_P.Text);
            if LocationVariableInP = 0 then
              if Variables_P.Text = EmptySymbol then Variables_P.Text := ArrayOfTempVariables
              else
                Variables_P.Text := Variables_P.Text + CommaAndSpaceSymbols + ArrayOfTempVariables;
          end;
        end;
      end;
      LineFromMemo := EmptySymbol;
    end;
  end;
end;


procedure TMetric.Search_Modified();
const
  EmptySymbol = '';
  CommaAndSpaceSymbols = ', ';
  EqualSymbol = '=';
  SpaceSymbol = ' ';
  Parenthesis = '(';
  SquareBracketRSymbol = '[';
  DoublePlus = '++';
  DoubleMinus = '--';
var
  i, j, k, SymbolsOverlap, h, LocationVariableInM: Integer;
  LineFromMemo, TempString : String;
begin
  LineFromMemo := EmptySymbol;
  for j := 1 to MaxArrayOfEachType do
    if ArrayValue[j] = EmptySymbol then break;
  k := j-1;

  for i := 1 to Memo.Lines.Count-2 do
  begin
    TempString := EmptySymbol;
    LineFromMemo := Memo.Lines[i];

    SymbolsOverlap := Pos(EqualSymbol, LineFromMemo);
    if SymbolsOverlap > 0 then
    begin
      for h := SymbolsOverlap-2 downto 1 do
        if (LineFromMemo[h] = SpaceSymbol) or (LineFromMemo[h] = Parenthesis) then break;
      TempString := copy(LineFromMemo,h+1,SymbolsOverlap-2);

      for h:= 1 to length(TempString) do
        if TempString[h] = SpaceSymbol then break;
      Delete(TempString,h,length(TempString)-h+1);

      for h:= 1 to length(TempString) do
        if TempString[h] = SquareBracketRSymbol then break;
      Delete(TempString,h,length(TempString)-h+1);

      for h := 1 to k do
        if TempString = ArrayValue[h] then break;
      LocationVariableInM := Pos(TempString, Variables_M.Text);  //Позиция переменной в Edit M
      if LocationVariableInM = 0 then
        if Variables_M.Text = EmptySymbol then Variables_M.Text := TempString
        else
          Variables_M.Text := Variables_M.Text + CommaAndSpaceSymbols + TempString;
    end;

    SymbolsOverlap := Pos(DoublePlus, LineFromMemo);
    if SymbolsOverlap > 0 then
    begin
      for h := SymbolsOverlap downto 1 do
        if (LineFromMemo[h] = SpaceSymbol)then break;
      TempString := copy(LineFromMemo,h+1,SymbolsOverlap-h-1);

      for h := 1 to k do
        if TempString = ArrayValue[h] then break;
      LocationVariableInM := Pos(TempString, Variables_M.Text);
      if LocationVariableInM = 0 then
        if Variables_M.Text = EmptySymbol then Variables_M.Text := TempString
        else
          Variables_M.Text := Variables_M.Text + CommaAndSpaceSymbols + TempString;
    end;

    SymbolsOverlap := Pos(DoubleMinus, LineFromMemo);
    if SymbolsOverlap > 0 then
    begin
      for h := SymbolsOverlap downto 1 do
        if (LineFromMemo[h] = SpaceSymbol)then break;
      TempString := copy(LineFromMemo,h+1,SymbolsOverlap-h-1);

      for h := 1 to k do
        if TempString = ArrayValue[h] then break;
      LocationVariableInM := Pos(TempString, Variables_M.Text);
      if LocationVariableInM = 0 then
        if Variables_M.Text = EmptySymbol then Variables_M.Text := TempString
        else
          Variables_M.Text := Variables_M.Text + CommaAndSpaceSymbols + TempString;
    end;
    TempString := EmptySymbol;
    LineFromMemo := EmptySymbol;
  end;
end;

//Поиск условий для while
procedure TMetric.Search(Overlap: Integer; LineFromMemo: String; k: Integer; send: Integer);
const
  EmptySymbol = '';
  SpaceSymbol = ' ';
  CommaAndSpaceSymbols = ', ';
  SemicolonSymbol = ';';
  ParenthesisR = '(';
  ParenthesisL = ')';
  SquareBracketRSymbol = '[';

var
  LocationVariableInC, i, TemporaryValues : Integer;
  FirstVariableOfCondition, SecVariableOfCondition : String;
begin
  if send = 0 then
  begin
    for i := 1 to length(LineFromMemo) do
      if LineFromMemo[i] = SemicolonSymbol then break;
    Delete(LineFromMemo,1,i+1);

    for i := 1 to length(LineFromMemo) do
      if LineFromMemo[i] = SemicolonSymbol then break;
    Delete(LineFromMemo,i,length(LineFromMemo)-i+1);
  end;

  if send = 1 then
  begin
    for i := Overlap+2 to length(LineFromMemo) do
      if LineFromMemo[i] = ParenthesisR then break;
    Delete(LineFromMemo,1,i);
  end;

  if send = 2 then
  begin
    for i := Overlap+5 to length(LineFromMemo) do
      if LineFromMemo[i] = ParenthesisR then break;
    Delete(LineFromMemo,1,i);
  end;

  if (send = 1) or (send = 2) then
  begin
  for i := 1 to length(LineFromMemo) do
    if LineFromMemo[i] = ParenthesisL then break;
  Delete(LineFromMemo,i,length(LineFromMemo)-i+1);
  end;

  for i := 1 to length(LineFromMemo) do
    if LineFromMemo[i] = SpaceSymbol then break;
  FirstVariableOfCondition := Copy(LineFromMemo,1,i-1);   //Первая переменная условия

  for i := length(LineFromMemo) downto 1 do
    if LineFromMemo[i] = SpaceSymbol then break;
  SecVariableOfCondition := Copy(LineFromMemo,i+1,length(LineFromMemo)-i+1);

  if send = 1 then
  begin
    for i := 1 to length(SecVariableOfCondition) do
      if SecVariableOfCondition[i] = SquareBracketRSymbol then break;
    Delete(SecVariableOfCondition,i,length(SecVariableOfCondition)-i+1);
  end;

  TemporaryValues := 0;
  for i := 1 to k do
    if FirstVariableOfCondition = ArrayValue[i] then
    begin
      TemporaryValues := 1;
      break;
    end;
  LocationVariableInC := Pos(FirstVariableOfCondition, Variables_C.Text);
  if (LocationVariableInC = 0) and (TemporaryValues = 1) then
    if Variables_C.Text = EmptySymbol then Variables_C.Text := FirstVariableOfCondition
    else
      Variables_C.Text := Variables_C.Text + CommaAndSpaceSymbols + FirstVariableOfCondition;

  TemporaryValues := 0;
  for i := 1 to k do
    if SecVariableOfCondition = ArrayValue[i] then
    begin
      TemporaryValues := 1;
      break;
    end;
  LocationVariableInC := Pos(SecVariableOfCondition, Variables_C.Text);
  if (LocationVariableInC = 0) and (TemporaryValues = 1) then
    if Variables_C.Text = EmptySymbol then Variables_C.Text := SecVariableOfCondition
    else
      Variables_C.Text := Variables_C.Text + CommaAndSpaceSymbols + SecVariableOfCondition;
end;


procedure TMetric.Search_Operation();
const
  EmptySymbol = '';
var
  i, j, k, Overlap : Integer;
  LineFromMemo : String;
begin
  LineFromMemo := EmptySymbol;
  for j := 1 to MaxArrayOfEachType do
    if ArrayValue[j] = EmptySymbol then break;
  k := j-1;

  for i := 1 to Memo.Lines.Count-2 do
  begin
    LineFromMemo := Memo.Lines[i];
    Overlap := Pos('for', LineFromMemo);
    if Overlap > 0 then Search(Overlap, LineFromMemo, k, 0);

    Overlap := Pos('if', LineFromMemo);
    if Overlap > 0 then Search(Overlap, LineFromMemo, k, 1);

    Overlap := Pos('while', LineFromMemo);
    if Overlap > 0 then Search(Overlap, LineFromMemo, k, 2);
  end;
end;




procedure TMetric.ButtonAnalysisClick(Sender: TObject);
const
  EmptySymbol = '';
  CommaSymbol = ','; CommaAndSpaceSymbols = ', ';
  MassageAllVariable = 'Всего переменных в программе = ';
  MassageVariableParasitesNotFound = 'Переменные типа Т отсутствуют';
  MassageVariableInputOutput = 'Переменных типа P = ';
  MassageVariableModified = 'Переменных типа M = ';
  MassageVariableOperation = 'Переменных типа C = ';
  MassageVariableParasites = 'Переменных типа T = ';
var
  i, j, Overlap, p_count, m_count, c_count, t_count : Integer;
  Result : Real;
  TempString : String;
begin
  for i := 1 to MaxArrayOfEachType do
    ArrayValue[i] := EmptySymbol;
  Recognition();
  Recognition_In_For();
  for i := 1 to MaxArrayOfEachType do
  begin
    if ArrayValue[i] = EmptySymbol then break;
    if i = 1 then ArrayOfVariable.Text := ArrayValue[i]
    else
      ArrayOfVariable.Text := ArrayOfVariable.Text + CommaAndSpaceSymbols + ArrayValue[i];
  end;
  showmessage(MassageAllVariable + inttostr(i-1));


  Search_Input_Output();
  Search_Modified();
  Search_Operation();

  p_count := 0;
  TempString := Variables_P.Text;
  for j := 1 to i do
  begin
    Overlap := Pos(ArrayValue[j], TempString);
    if (Overlap = 0) and (ArrayValue[j] <> EmptySymbol) then
    begin
      inc(p_count);
      Array_Not_Found_P[p_count] := ArrayValue[j];
    end;
  end;

  m_count := 0;
  TempString := Variables_M.Text;
  for j := 1 to p_count do
  begin
    Overlap := Pos(Array_Not_Found_P[j], TempString);
    if (Overlap = 0) and (Array_Not_Found_P[j] <> EmptySymbol) then
    begin
      inc(m_count);
      Array_Not_Found_M[m_count] := Array_Not_Found_P[j];
    end;
  end;

  c_count := 0;
  TempString := Variables_C.Text;
  for j := 1 to m_count do
  begin
    Overlap := Pos(Array_Not_Found_M[j], TempString);
    if (Overlap = 0) and (Array_Not_Found_M[j] <> EmptySymbol) then
    begin
      inc(c_count);
      Array_Not_Found_C[c_count] := Array_Not_Found_M[j];
    end;
  end;

  t_count := 0;
  if c_count = 0 then Variables_T.Text :=  MassageVariableParasitesNotFound
  else
  for j := 1 to c_count do
    if j = 1 then
      Variables_T.Text := Array_Not_Found_C[j]
    else
      Variables_T.Text := Variables_T.Text + CommaAndSpaceSymbols + Array_Not_Found_C[j];

  TempString := Variables_T.Text;
  if TempString <> MassageVariableParasitesNotFound then t_count := 1;

  p_count := 0;
  TempString := Variables_P.Text;
  for i := 1 to length(TempString) do
    if TempString[i] = CommaSymbol then inc(p_count);
  if p_count <> 0 then inc(p_count);
  showmessage(MassageVariableInputOutput + inttostr(p_count));

  m_count := 0;
  TempString := Variables_M.Text;
  for i := 1 to length(TempString) do
    if TempString[i] = CommaSymbol then inc(m_count);
  if m_count <> 0 then inc(m_count);
  showmessage(MassageVariableModified + inttostr(m_count));

  c_count := 0;
  TempString := Variables_C.Text;
  for i := 1 to length(TempString) do
    if TempString[i] = CommaSymbol then inc(c_count);
  if c_count <> 0 then inc(c_count);
  showmessage(MassageVariableOperation + inttostr(c_count));

  TempString := Variables_T.Text;
  for i := 1 to length(TempString) do
    if TempString[i] = CommaSymbol then inc(t_count);
  showmessage(MassageVariableParasites + inttostr(t_count));

  Result := p_count + 2*m_count + 3*c_count + 0.5*t_count;
  MetricResult.Text := floattostr(Result);
end;


end.
