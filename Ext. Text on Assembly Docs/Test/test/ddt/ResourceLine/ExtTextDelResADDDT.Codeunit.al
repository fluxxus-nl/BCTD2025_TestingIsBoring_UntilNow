codeunit 76473 "Ext. Text Del. Res. AD DDT FLX"
{
    // Generated on 2025-06-07 by lvanvugt

    Subtype = Test;

    trigger OnRun()
    begin
        // [FEATURE] Extended Text on assembly document/Delete resource line
    end;

    [Test]
    procedure DeleteResourceLineWithExtendedText()
    var
        AssemblyDocumentType: Enum "Assembly Document Type";
        AutomaticExtTextsEnabled, ExtendedTextEnabled : Boolean;
        AssemblyDocNo: Code[20];
        ResourceNo: Code[20];
    begin
        // [SCENARIO #0031] Delete resource line with extended text
        // [SCENARIO #0038] Delete resource line with extended text
        // [SCENARIO #0045] Delete resource line with extended text
        Initialize();

        AssemblyDocumentType := GetAssemblyDocumentType();
        AutomaticExtTextsEnabled := AITTestContext.GetTestSetup().Element('Automatic Ext. Texts Enabled').ValueAsBoolean();
        ExtendedTextEnabled := AITTestContext.GetTestSetup().Element('Extended Text Enabled').ValueAsBoolean();

        // [GIVEN] Resource with "Automatic Ext. Texts" disabled and extended text enabled for assembly order
        ResourceNo := CreateResourceWithExtendedText(AutomaticExtTextsEnabled, AssemblyDocumentType, ExtendedTextEnabled);
        // [GIVEN] Assembly order with resource line and extended text inserted
        AssemblyDocNo := CreateAssemblyOrderWithResourceLineAndExtendedTextInserted(AssemblyDocumentType, ResourceNo);

        // [WHEN] Delete resource line from assembly order
        DeleteResourceLineFromAssemblyOrder(AssemblyDocumentType, AssemblyDocNo, ResourceNo);

        // [THEN] Resource  and extended text lines are removed
        VerifyResourceAndExtendedTextLinesAreRemoved(AssemblyDocumentType, AssemblyDocNo, ResourceNo);
    end;

    var
        LibraryExtTextAssDoc: Codeunit "Library - Ext Text Ass Doc FLX";
        AITTestContext: Codeunit "AIT Test Context";
        IsInitialized: Boolean;

    local procedure Initialize()
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize FLX";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Ext. Text Del. Res. AD DDT FLX");

        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Ext. Text Del. Res. AD DDT FLX");

        // [GIVEN] Set Nos on assembly setup
        SetNosOnAssemblySetup();

        IsInitialized := true;
        Commit();

        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Ext. Text Del. Res. AD DDT FLX");
    end;

    local procedure SetNosOnAssemblySetup()
    begin
        LibraryExtTextAssDoc.SetNosOnAssemblySetup();
    end;

    local procedure CreateAssemblyDocument(AssemblyDocumentType: Enum "Assembly Document Type"): Code[20]
    begin
        exit(LibraryExtTextAssDoc.CreateAssemblyDocument(AssemblyDocumentType));
    end;

    local procedure CreateAssemblyDocumentWithResourceLine(AssemblyDocumentType: Enum "Assembly Document Type"; ResourceNo: Code[20]): Code[20]
    var
        AssemblyHeader: Record "Assembly Header";
        AssemblyLine: Record "Assembly Line";
        LibraryAssembly: Codeunit "Library - Assembly 2 FLX";
        AssemblyDocNo: Code[20];
    begin
        AssemblyDocNo := CreateAssemblyDocument(AssemblyDocumentType);
        AssemblyHeader.Get(AssemblyDocumentType, AssemblyDocNo);
        LibraryAssembly.CreateAssemblyLine(AssemblyHeader, AssemblyLine, AssemblyLine.Type::Resource, ResourceNo, LibraryExtTextAssDoc.CreateResourceUnitOfMeasureCode(ResourceNo), 1, 1, '');
        exit(AssemblyHeader."No.");
    end;

    local procedure CreateAssemblyOrderWithResourceLineAndExtendedTextInserted(AssemblyDocumentType: Enum "Assembly Document Type"; ResourceNo: Code[20]): Code[20]
    var
        AssemblyDocNo: Code[20];
    begin
        AssemblyDocNo := CreateAssemblyDocumentWithResourceLine(AssemblyDocumentType, ResourceNo);
        InsertExtendedText(AssemblyDocumentType, AssemblyDocNo, ResourceNo);
        exit(AssemblyDocNo);
    end;

    local procedure CreateResourceWithExtendedText(AutomaticExtTextsEnabled: Boolean; AssemblyDocumentType: Enum "Assembly Document Type"; ExtendedTextEnabled: Boolean): Code[20]
    begin
        exit(LibraryExtTextAssDoc.CreateResourceWithExtendedText(AutomaticExtTextsEnabled, AssemblyDocumentType, ExtendedTextEnabled));
    end;

    local procedure DeleteResourceLineFromAssemblyOrder(AssemblyDocumentType: Enum "Assembly Document Type"; AssemblyDocNo: Code[20]; ResourceNo: Code[20])
    var
        AssemblyLine: Record "Assembly Line";
    begin
        LibraryExtTextAssDoc.DeleteLineFromAssemblyDocument(AssemblyDocumentType, AssemblyDocNo, AssemblyLine.Type::Resource, ResourceNo);
    end;

    local procedure InsertExtendedText(AssemblyDocumentType: Enum "Assembly Document Type"; AssemblyDocNo: Code[20]; ResourceNo: Code[20])
    var
        AssemblyLine: Record "Assembly Line";
    begin
        LibraryExtTextAssDoc.InsertExtendedText(AssemblyDocumentType, AssemblyDocNo, AssemblyLine.Type::Resource, ResourceNo);
    end;

    local procedure VerifyResourceAndExtendedTextLinesAreRemoved(AssemblyDocumentType: Enum "Assembly Document Type"; AssemblyDocNo: Code[20]; ResourceNo: Code[20])
    var
        AssemblyLine: Record "Assembly Line";
    begin
        LibraryExtTextAssDoc.VerifyResourceAndExtendedTextLinesAreRemoved(AssemblyDocumentType, AssemblyDocNo, ResourceNo);
    end;

    local procedure GetAssemblyDocumentType(): Enum "Assembly Document Type"
    var
        AssemblyDocumentType: Text;
    begin
        exit(LibraryExtTextAssDoc.GetAssemblyDocumentType());
    end;
}