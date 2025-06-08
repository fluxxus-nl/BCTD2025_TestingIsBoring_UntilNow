codeunit 76471 "Ext. Text Del. Text AD DDT FLX"
{
    // Generated on 2025-06-07 by lvanvugt

    Subtype = Test;

    trigger OnRun()
    begin
        // [FEATURE] Extended Text on assembly document/Delete text line
    end;

    [Test]
    procedure DeleteTextLineWithExtendedText()
    var
        AssemblyDocumentType: Enum "Assembly Document Type";
        ExtendedTextEnabled: Boolean;
        AssemblyDocNo: Code[20];
        TextCode: Code[20];
    begin
        // [SCENARIO #0052] Delete text line with extended text
        // [SCENARIO #0059] Delete text line with extended text
        // [SCENARIO #0066] Delete text line with extended text
        Initialize();

        AssemblyDocumentType := GetAssemblyDocumentType();
        ExtendedTextEnabled := AITTestContext.GetTestSetup().Element('Extended Text Enabled').ValueAsBoolean();


        // [GIVEN] Standard text with extended text enabled for assembly document
        TextCode := CreateStandardTextWithExtendedText(AssemblyDocumentType, ExtendedTextEnabled);
        // [GIVEN] Assembly document with text line and extended text inserted
        AssemblyDocNo := CreateAssemblyDocumentWithTextLineAndExtendedTextInserted(AssemblyDocumentType, TextCode);

        // [WHEN] Delete text line from assembly document
        DeleteTextLineFromAssemblyDocument(AssemblyDocumentType, AssemblyDocNo, TextCode);

        // [THEN] Text  and extended text lines are removed
        VerifyTextAndExtendedTextLinesAreRemoved(AssemblyDocumentType, AssemblyDocNo, TextCode);
    end;

    var
        LibraryExtTextAssDoc: Codeunit "Library - Ext Text Ass Doc FLX";
        AITTestContext: Codeunit "AIT Test Context";
        IsInitialized: Boolean;

    local procedure Initialize()
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize FLX";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Ext. Text Del. Text AD DDT FLX");

        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Ext. Text Del. Text AD DDT FLX");

        // [GIVEN] Set Nos on assembly setup
        SetNosOnAssemblySetup();

        IsInitialized := true;
        Commit();

        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Ext. Text Del. Text AD DDT FLX");
    end;

    local procedure SetNosOnAssemblySetup()
    begin
        LibraryExtTextAssDoc.SetNosOnAssemblySetup();
    end;

    local procedure CreateAssemblyDocument(AssemblyDocumentType: Enum "Assembly Document Type"): Code[20]
    begin
        exit(LibraryExtTextAssDoc.CreateAssemblyDocument(AssemblyDocumentType));
    end;

    local procedure CreateAssemblyDocumentWithTextLine(AssemblyDocumentType: Enum "Assembly Document Type"; TextCode: Code[20]): Code[20]
    var
        AssemblyHeader: Record "Assembly Header";
        AssemblyLine: Record "Assembly Line";
        LibraryAssembly: Codeunit "Library - Assembly 2 FLX";
        AssemblyDocNo: Code[20];
    begin
        AssemblyDocNo := CreateAssemblyDocument(AssemblyDocumentType);
        AssemblyHeader.Get(AssemblyDocumentType, AssemblyDocNo);
        LibraryAssembly.CreateAssemblyLine(AssemblyHeader, AssemblyLine, AssemblyLine.Type::" ", TextCode, '', 0, 0, '');
        exit(AssemblyHeader."No.");
    end;

    local procedure CreateAssemblyDocumentWithTextLineAndExtendedTextInserted(AssemblyDocumentType: Enum "Assembly Document Type"; TextCode: Code[20]): Code[20]
    var
        AssemblyDocNo: Code[20];
    begin
        AssemblyDocNo := CreateAssemblyDocumentWithTextLine(AssemblyDocumentType, TextCode);
        InsertExtendedText(AssemblyDocumentType, AssemblyDocNo, TextCode);
        exit(AssemblyDocNo);
    end;

    local procedure CreateStandardTextWithExtendedText(AssemblyDocumentType: Enum "Assembly Document Type"; ExtendedTextEnabled: Boolean): Code[20]
    begin
        exit(LibraryExtTextAssDoc.CreateStandardTextWithExtendedText(AssemblyDocumentType, ExtendedTextEnabled));
    end;

    local procedure DeleteTextLineFromAssemblyDocument(AssemblyDocumentType: Enum "Assembly Document Type"; AssemblyDocNo: Code[20]; TextCode: Code[20])
    var
        AssemblyLine: Record "Assembly Line";
    begin
        LibraryExtTextAssDoc.DeleteLineFromAssemblyDocument(AssemblyDocumentType, AssemblyDocNo, AssemblyLine.Type::" ", TextCode);
    end;

    local procedure InsertExtendedText(AssemblyDocumentType: Enum "Assembly Document Type"; AssemblyDocNo: Code[20]; TextCode: Code[20])
    var
        AssemblyLine: Record "Assembly Line";
    begin
        LibraryExtTextAssDoc.InsertExtendedText(AssemblyDocumentType, AssemblyDocNo, AssemblyLine.Type::" ", TextCode);
    end;

    local procedure VerifyExtendedTextLinesAreAddedToAssemblyDocument(AssemblyDocumentType: Enum "Assembly Document Type"; AssemblyDocNo: Code[20]; TextCode: Code[20]; CreatedNoOfExtendedTextLines: Integer)
    var
        AssemblyLine: Record "Assembly Line";
    begin
        LibraryExtTextAssDoc.VerifyExtendedTextLinesAreAddedToAssemblyDocument(AssemblyDocumentType, AssemblyDocNo, AssemblyLine.Type::" ", TextCode, CreatedNoOfExtendedTextLines);
    end;

    local procedure VerifyTextAndExtendedTextLinesAreRemoved(AssemblyDocumentType: Enum "Assembly Document Type"; AssemblyDocNo: Code[20]; TextCode: Code[20])
    var
        AssemblyHeader: Record "Assembly Header";
    begin
        LibraryExtTextAssDoc.VerifyTextAndExtendedTextLinesAreRemoved(AssemblyDocumentType, AssemblyDocNo, TextCode);
    end;

    local procedure GetAssemblyDocumentType(): Enum "Assembly Document Type"
    var
        AssemblyDocumentType: Text;
    begin
        exit(LibraryExtTextAssDoc.GetAssemblyDocumentType());
    end;
}