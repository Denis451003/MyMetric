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
    procedure Search(x: Integer; LineFromMemo: String; k: Integer; send: Integer);
    procedure Search_Operation();
    procedure ButtonAnalysisClick(Sender: TObject);



  private
    { Private declarations }
  public
    { Public declarations }
  end;
const
  MaxArrayOfEachType = 100;   //   Максивальный размер массива каждого из типов

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


//Преобразование кода (очистка)
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

 //Распознание переменных и создание массива из них НЕ в for
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
  i, j, k, z, count, NumberOfCommas,x, y, h : Integer;
  LineFromMemo, TempTypesString, TempString, TempSymbolsString : String;
begin
  LineFromMemo := EmptySymbol; //Строка из мемо
  TempTypesString := EmptySymbol;   // Временная строка
  TempString := EmptySymbol;    //Временная строка
  TempSymbolsString :=  EmptySymbol;   //Временная строка
  count := 0;                                       //Счётчик массива переменных
  NumberOfCommas := 0;     //Кол-во запятых
  for i := 1 to Memo.Lines.Count-2 do
  begin
    k := 0;
    LineFromMemo := Memo.Lines[i];

    for j:=1 to length(LineFromMemo) do
      if LineFromMemo[j] = SpaceSymbol then break;
    TempTypesString := copy(LineFromMemo,1,j-1);

    if (TempTypesString = typeChar) or (TempTypesString = typeShort) or (TempTypesString = typeInt)  then k := 1;
    if (TempTypesString = typeLong) or (TempTypesString = typeFloat) or (TempTypesString = typeDouble)  then k := 1;
    if (TempTypesString = typeVoid) or (TempTypesString = typeSigned) or (TempTypesString = typeUnsigned)  then k := 1;

    if k = 1 then
    begin
      TempString := copy(LineFromMemo,j+1,length(LineFromMemo)-j);
      for x := 1 to length(TempString) do
      begin
        if TempString[x] = CommaSymbol then inc(NumberOfCommas);
        if TempString[x] = BraceRSymbol then break;
      end;
      y := 0;
      z := 1;

      while y <= NumberOfCommas do
      begin
        for x := z to length(TempString) do
          if (TempString[x] = CommaSymbol) then break;
        TempSymbolsString := copy(TempString,z,x-z);
        if TempString[x+1] = SpaceSymbol then z := x+2;
        if TempString[x+1] <> SpaceSymbol then z := x+1;
        h := 1;
        while h <= length(TempSymbolsString) do
        begin
          if (TempSymbolsString[h] = SquareBracketRSymbol) or (TempSymbolsString[h] = SquareBracketLSymbol) then
          begin
            Delete(TempSymbolsString,h,1);
            h := h-2;
          end;
          if (TempSymbolsString[h] = EqualSymbol) or (TempSymbolsString[h] = SemicolonSymbol) or (TempSymbolsString[h] = SpaceSymbol) then
          begin
            Delete(TempSymbolsString,h,1);
            h := h-2;
          end;
          if (TempSymbolsString[h] = SymbolOfZero) or (TempSymbolsString[h] = SymbolOfUnit) or (TempSymbolsString[h] = SymbolOfDeuces) then
          begin
            Delete(TempSymbolsString,h,1);
            h := h-2;
          end;
          if (TempSymbolsString[h] = SymbolOfThee) or (TempSymbolsString[h] = SymbolOfFour) then
          begin
            Delete(TempSymbolsString,h,1);
            h := h-2;
          end;
          if (TempSymbolsString[h] = SymbolOfFive) or (TempSymbolsString[h] = SymbolOfSix) then
          begin
            Delete(TempSymbolsString,h,1);
            h := h-2;
          end;
          if (TempSymbolsString[h] = SymbolOfSeven) or (TempSymbolsString[h] = SymbolOfEight) or (TempSymbolsString[h] = SymbolOfNine) then
          begin
            Delete(TempSymbolsString,h,1);
            h := h-2;
          end;
          if (TempSymbolsString[h] = BraceRSymbol) or (TempSymbolsString[h] = BraceLSymbol)then
          begin
            Delete(TempSymbolsString,h,1);
            h := h-2;
          end;
          inc(h);
        end;

        inc(count);
        ArrayValue[count] := TempSymbolsString;
        inc(y);
        TempSymbolsString := EmptySymbol;
      end;
    end;
    LineFromMemo := EmptySymbol;
    TempTypesString := EmptySymbol;
    TempString := EmptySymbol;
    NumberOfCommas := 0;
  end;
end;

//Распознание переменных и создание массива из них в for
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
  i,  k, x, h : Integer;
  LineFromMemo, TempSymbolsString, TypeInFor : String;
  Overlap : Integer;
begin
  LineFromMemo := EmptySymbol;
  TypeInFor := EmptySymbol;
  h := 0;
  for i := 1 to Memo.Lines.Count-2 do
  begin
    LineFromMemo := Memo.Lines[i];
    Overlap := Pos(InstructionFor,LineFromMemo);


    if Overlap <> 0 then TempSymbolsString := copy(LineFromMemo,6,length(LineFromMemo)-6);
    if TempSymbolsString <> EmptySymbol then
    begin

      for k := 1 to length(TempSymbolsString) do
        if TempSymbolsString[k] = SemicolonSymbol then break;
      Delete(TempSymbolsString,k-4,length(TempSymbolsString)-k+5);

      for x := 1 to length(TempSymbolsString) do
        if TempSymbolsString[x] = SpaceSymbol then break;
      TypeInFor := copy(TempSymbolsString,1,x-1);   //хранит тип в фор

      if (TypeInFor = typeChar) or (TypeInFor = typeShort) or (TypeInFor = typeInt)  then h := x;
      if (TypeInFor = typeLong) or (TypeInFor = typeFloat) or (TypeInFor = typeDouble)  then h := x;
      if (TypeInFor = typeVoid) or (TypeInFor = typeSigned) or (TypeInFor = typeUnsigned)  then h := x;

      if h <> 0 then
      begin
        for x := 1 to length(TempSymbolsString) do
          if TempSymbolsString[x] = SpaceSymbol then break;
        Delete(TempSymbolsString,1,x);
        for x := 1 to MaxArrayOfEachType do
          if ArrayValue[x] = EmptySymbol then break;
        ArrayValue[x] := TempSymbolsString;
      end;
    end;
    h := 0;
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
  i, j, k, z, x, h, count, LocationVariableInP : Integer;
  LineFromMemo, ArrayOfTempVariables : String;
begin
  LineFromMemo := EmptySymbol;
  for j := 1 to MaxArrayOfEachType do
    if ArrayValue[j] = EmptySymbol then break;
  k := j-1;

  for j := 1 to k do
  begin
    ArrayOfTempVariables := ArrayValue[j]; //Массив переменных(временных)

    for i := 1 to Memo.Lines.Count-2 do
    begin
      LineFromMemo := Memo.Lines[i];
      z := Pos(ArrayOfTempVariables,LineFromMemo);

      if z > 0 then
      begin
        x := Pos(Printf, LineFromMemo);
        if x > 0 then
        begin
          for h := 1 to length(LineFromMemo) do
            if LineFromMemo[h] = CommaSymbol then break;
          Delete(LineFromMemo,1,h);
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

        x := Pos(Scanf, LineFromMemo);
        if x > 0 then
        begin
          for h := 1 to length(LineFromMemo) do
            if LineFromMemo[h] = ',' then break;
          Delete(LineFromMemo,1,h);
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

//Поиск модифицируемых переменных (M)
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
  i, j, k, x, h, LocationVariableInM: Integer;
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

    x := Pos(EqualSymbol, LineFromMemo);
    if x > 0 then
    begin
      for h := x-2 downto 1 do
        if (LineFromMemo[h] = SpaceSymbol) or (LineFromMemo[h] = Parenthesis) then break;
      TempString := copy(LineFromMemo,h+1,x-2);

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

    x := Pos(DoublePlus, LineFromMemo);
    if x > 0 then
    begin
      for h := x downto 1 do
        if (LineFromMemo[h] = SpaceSymbol)then break;
      TempString := copy(LineFromMemo,h+1,x-h-1);

      for h := 1 to k do
        if TempString = ArrayValue[h] then break;
      LocationVariableInM := Pos(TempString, Variables_M.Text);
      if LocationVariableInM = 0 then
        if Variables_M.Text = EmptySymbol then Variables_M.Text := TempString
        else
          Variables_M.Text := Variables_M.Text + CommaAndSpaceSymbols + TempString;
    end;

    x := Pos(DoubleMinus, LineFromMemo);
    if x > 0 then
    begin
      for h := x downto 1 do
        if (LineFromMemo[h] = SpaceSymbol)then break;
      TempString := copy(LineFromMemo,h+1,x-h-1);

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
procedure TMetric.Search(x: Integer; LineFromMemo: String; k: Integer; send: Integer);
const
  EmptySymbol = '';
  SpaceSymbol = ' ';
  CommaAndSpaceSymbols = ', ';
  SemicolonSymbol = ';';
  ParenthesisR = '(';
  ParenthesisL = ')';
  SquareBracketRSymbol = '[';

var
  LocationVariableInC, h, z : Integer;
  FirstVariableOfCondition, SecVariableOfCondition : String;
begin
  if send = 0 then
  begin
    for h := 1 to length(LineFromMemo) do
      if LineFromMemo[h] = SemicolonSymbol then break;
    Delete(LineFromMemo,1,h+1);

    for h := 1 to length(LineFromMemo) do
      if LineFromMemo[h] = SemicolonSymbol then break;
    Delete(LineFromMemo,h,length(LineFromMemo)-h+1);
  end;

  if send = 1 then
  begin
    for h := x+2 to length(LineFromMemo) do
      if LineFromMemo[h] = ParenthesisR then break;
    Delete(LineFromMemo,1,h);
  end;

  if send = 2 then
  begin
    for h := x+5 to length(LineFromMemo) do
      if LineFromMemo[h] = ParenthesisR then break;
    Delete(LineFromMemo,1,h);
  end;

  if (send = 1) or (send = 2) then
  begin
  for h := 1 to length(LineFromMemo) do
    if LineFromMemo[h] = ParenthesisL then break;
  Delete(LineFromMemo,h,length(LineFromMemo)-h+1);
  end;

  for h := 1 to length(LineFromMemo) do
    if LineFromMemo[h] = SpaceSymbol then break;
  FirstVariableOfCondition := Copy(LineFromMemo,1,h-1);   //Первая переменная условия

  for h := length(LineFromMemo) downto 1 do
    if LineFromMemo[h] = SpaceSymbol then break;
  SecVariableOfCondition := Copy(LineFromMemo,h+1,length(LineFromMemo)-h+1);

  if send = 1 then
  begin
    for h := 1 to length(SecVariableOfCondition) do
      if SecVariableOfCondition[h] = SquareBracketRSymbol then break;
    Delete(SecVariableOfCondition,h,length(SecVariableOfCondition)-h+1);
  end;

  z := 0;
  for h := 1 to k do
    if FirstVariableOfCondition = ArrayValue[h] then
    begin
      z := 1;
      break;
    end;
  LocationVariableInC := Pos(FirstVariableOfCondition, Variables_C.Text);
  if (LocationVariableInC = 0) and (z = 1) then
    if Variables_C.Text = EmptySymbol then Variables_C.Text := FirstVariableOfCondition
    else
      Variables_C.Text := Variables_C.Text + CommaAndSpaceSymbols + FirstVariableOfCondition;

  z := 0;
  for h := 1 to k do
    if SecVariableOfCondition = ArrayValue[h] then
    begin
      z := 1;
      break;
    end;
  LocationVariableInC := Pos(SecVariableOfCondition, Variables_C.Text);
  if (LocationVariableInC = 0) and (z = 1) then
    if Variables_C.Text = EmptySymbol then Variables_C.Text := SecVariableOfCondition
    else
      Variables_C.Text := Variables_C.Text + CommaAndSpaceSymbols + SecVariableOfCondition;
end;

//Поиск переменных управления (С)
procedure TMetric.Search_Operation();
const
  EmptySymbol = '';
var
  i, j, k, x : Integer;
  LineFromMemo : String;
begin
  LineFromMemo := EmptySymbol;
  for j := 1 to MaxArrayOfEachType do
    if ArrayValue[j] = EmptySymbol then break;
  k := j-1;

  for i := 1 to Memo.Lines.Count-2 do
  begin
    LineFromMemo := Memo.Lines[i];
    x := Pos('for', LineFromMemo);
    if x > 0 then Search(x, LineFromMemo, k, 0);

    x := Pos('if', LineFromMemo);
    if x > 0 then Search(x, LineFromMemo, k, 1);

    x := Pos('while', LineFromMemo);
    if x > 0 then Search(x, LineFromMemo, k, 2);
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
  i, j, k, p_count, m_count, c_count, t_count : Integer;
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
    k := Pos(ArrayValue[j], TempString);
    if (k = 0) and (ArrayValue[j] <> EmptySymbol) then
    begin
      inc(p_count);
      Array_Not_Found_P[p_count] := ArrayValue[j];
    end;
  end;

  m_count := 0;
  TempString := Variables_M.Text;
  for j := 1 to p_count do
  begin
    k := Pos(Array_Not_Found_P[j], TempString);
    if (k = 0) and (Array_Not_Found_P[j] <> EmptySymbol) then
    begin
      inc(m_count);
      Array_Not_Found_M[m_count] := Array_Not_Found_P[j];
    end;
  end;

  c_count := 0;
  TempString := Variables_C.Text;
  for j := 1 to m_count do
  begin
    k := Pos(Array_Not_Found_M[j], TempString);
    if (k = 0) and (Array_Not_Found_M[j] <> EmptySymbol) then
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
