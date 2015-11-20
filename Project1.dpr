program Project1;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Metric};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMetric, Metric);
  Application.Run;
end.
