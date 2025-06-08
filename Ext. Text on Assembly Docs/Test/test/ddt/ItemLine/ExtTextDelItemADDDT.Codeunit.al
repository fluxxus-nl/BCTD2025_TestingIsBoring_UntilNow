codeunit 76472 "Ext. Text Del. Item AD DDT FLX"
{
    // Generated on 2025-06-07 by lvanvugt

    Subtype = Test;

    trigger OnRun()
    begin
        // [FEATURE] Extended Text on assembly document/Delete item line
    end;

    [Test]
    procedure DeleteItemLineWithExtendedTextOnAssemblyDocument()
    var
        AssemblyDocumentType: Enum "Assembly Document Type";
        AutomaticExtTextsEnabled, ExtendedTextEnabled : Boolean;
        AssemblyDocNo: Code[20];
        ItemNo: Code[20];
    begin
        // [SCENARIO #0005] Delete item line with extended text from assembly order
        // [SCENARIO #0010] Delete item line with extended text from assembly quote
        // [SCENARIO #0015] Delete item line with extended text from assembly blanket order
        Initialize();

        AssemblyDocumentType := GetAssemblyDocumentType();
        AutomaticExtTextsEnabled := AITTestContext.GetTestSetup().Element('Automatic Ext. Texts Enabled').ValueAsBoolean();
        ExtendedTextEnabled := AITTestContext.GetTestSetup().Element('Extended Text Enabled').ValueAsBoolean();

        // [GIVEN] Item with "Automatic Ext. Texts" disabled and extended text enabled for assembly document
        ItemNo := CreateItemWithExtendedText(AutomaticExtTextsEnabled, AssemblyDocumentType, ExtendedTextEnabled);
        // [GIVEN] Assembly document with item line and extended text inserted
        AssemblyDocNo := CreateAssemblyDocumentWithItemLineAndExtendedTextInserted(AssemblyDocumentType, ItemNo);

        // [WHEN] Delete item line from assembly order
        DeleteItemLineFromAssemblyOrder(AssemblyDocumentType, AssemblyDocNo, ItemNo);

        // [THEN] Item  and extended text lines are removed
        VerifyItemAndExtendedTextLinesAreRemoved(AssemblyDocumentType, AssemblyDocNo, ItemNo);
    end;

    var
        LibraryExtTextAssDoc: Codeunit "Library - Ext Text Ass Doc FLX";
        AITTestContext: Codeunit "AIT Test Context";
        IsInitialized: Boolean;

    local procedure Initialize()
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize FLX";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Ext. Text Del. Item AD DDT FLX");

        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Ext. Text Del. Item AD DDT FLX");

        // [GIVEN] Set Nos on assembly setup
        SetNosOnAssemblySetup();

        IsInitialized := true;
        Commit();

        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Ext. Text Del. Item AD DDT FLX");
    end;

    local procedure SetNosOnAssemblySetup()
    begin
        LibraryExtTextAssDoc.SetNosOnAssemblySetup();
    end;

    local procedure CreateAssemblyDocument(AssemblyDocumentType: Enum "Assembly Document Type"): Code[20]
    begin
        exit(LibraryExtTextAssDoc.CreateAssemblyDocument(AssemblyDocumentType));
    end;

    local procedure CreateAssemblyDocumentWithItemLine(AssemblyDocumentType: Enum "Assembly Document Type"; ItemNo: Code[20]): Code[20]
    var
        AssemblyHeader: Record "Assembly Header";
        AssemblyLine: Record "Assembly Line";
        LibraryAssembly: Codeunit "Library - Assembly 2 FLX";
        AssemblyDocNo: Code[20];
    begin
        AssemblyDocNo := CreateAssemblyDocument(AssemblyDocumentType);
        AssemblyHeader.Get(AssemblyDocumentType, AssemblyDocNo);
        LibraryAssembly.CreateAssemblyLine(AssemblyHeader, AssemblyLine, AssemblyLine.Type::Item, ItemNo, LibraryExtTextAssDoc.CreateItemUnitOfMeasureCode(ItemNo), 1, 1, '');
        exit(AssemblyHeader."No.");
    end;

    local procedure CreateAssemblyDocumentWithItemLineAndExtendedTextInserted(AssemblyDocumentType: Enum "Assembly Document Type"; ItemNo: Code[20]): Code[20]
    var
        AssemblyDocNo: Code[20];
    begin
        AssemblyDocNo := CreateAssemblyDocumentWithItemLine(AssemblyDocumentType, ItemNo);
        InsertExtendedText(AssemblyDocumentType, AssemblyDocNo, ItemNo);
        exit(AssemblyDocNo);
    end;

    local procedure CreateItemWithExtendedText(AutomaticExtTextsEnabled: Boolean; AssemblyDocumentType: Enum "Assembly Document Type"; ExtendedTextEnabled: Boolean): Code[20]
    begin
        exit(LibraryExtTextAssDoc.CreateItemWithExtendedText(AutomaticExtTextsEnabled, AssemblyDocumentType, ExtendedTextEnabled));
    end;

    local procedure DeleteItemLineFromAssemblyOrder(AssemblyDocumentType: Enum "Assembly Document Type"; AssemblyDocNo: Code[20]; ItemNo: Code[20])
    var
        AssemblyLine: Record "Assembly Line";
    begin
        LibraryExtTextAssDoc.DeleteLineFromAssemblyDocument(AssemblyDocumentType, AssemblyDocNo, AssemblyLine.Type::Item, ItemNo);
    end;

    local procedure InsertExtendedText(AssemblyDocumentType: Enum "Assembly Document Type"; AssemblyDocNo: Code[20]; ItemNo: Code[20])
    var
        AssemblyLine: Record "Assembly Line";
    begin
        LibraryExtTextAssDoc.InsertExtendedText(AssemblyDocumentType, AssemblyDocNo, AssemblyLine.Type::Item, ItemNo);
    end;

    local procedure VerifyExtendedTextLinesAreAddedToAssemblyDocument(AssemblyDocumentType: Enum "Assembly Document Type"; AssemblyDocNo: Code[20]; ItemNo: Code[20]; CreatedNoOfExtendedTextLines: Integer)
    var
        AssemblyLine: Record "Assembly Line";
    begin
        LibraryExtTextAssDoc.VerifyExtendedTextLinesAreAddedToAssemblyDocument(AssemblyDocumentType, AssemblyDocNo, AssemblyLine.Type::Item, ItemNo, CreatedNoOfExtendedTextLines);
    end;

    local procedure VerifyItemAndExtendedTextLinesAreRemoved(AssemblyDocumentType: Enum "Assembly Document Type"; AssemblyDocNo: Code[20]; ItemNo: Code[20])
    var
        AssemblyHeader: Record "Assembly Header";
    begin
        LibraryExtTextAssDoc.VerifyItemAndExtendedTextLinesAreRemoved(AssemblyDocumentType, AssemblyDocNo, ItemNo);
    end;

    local procedure GetAssemblyDocumentType(): Enum "Assembly Document Type"
    var
        AssemblyDocumentType: Text;
    begin
        exit(LibraryExtTextAssDoc.GetAssemblyDocumentType());
    end;
}