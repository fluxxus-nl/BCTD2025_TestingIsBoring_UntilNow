codeunit 76470 "Library - Test Initialize FLX"
{

    trigger OnRun()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnTestInitialize(CallerCodeunitID: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeTestSuiteInitialize(CallerCodeunitID: Integer)
    begin
    end;

    [IntegrationEvent(true, false)]
    procedure OnAfterTestSuiteInitialize(CallerCodeunitID: Integer)
    begin
    end;
}

