codeunit 76464 "Ext. Text Ins. Item AD DDT FLX"
{
    // Generated on 2025-06-07 by lvanvugt

    Subtype = Test;

    trigger OnRun()
    begin
        // [FEATURE] Extended Text for inserted item line on assembly document
    end;

    [Test]
    procedure InsertExtendedTextsForItemOnAssemblyDocument()
    // [FEATURE] Extended Text on assembly document/Add item line
    var
        AssemblyDocumentType: Enum "Assembly Document Type";
        AutomaticExtTextsEnabled, ExtendedTextEnabled : Boolean;
        CreatedNoOfExtendedTextLines, TargettedNoOfExtendedTextLines : Integer;
        AssemblyDocNo: Code[20];
        ItemNo: Code[20];
    begin
        // [SCENARIO #0003] Insert extended texts for item with extended texts on assembly order line
        // [SCENARIO #0004] Insert extended texts for item with no extended texts on assembly order line
        // [SCENARIO #0019] Insert extended texts twice for item with extended texts on assembly order line
        // [SCENARIO #0008] Insert extended texts for item with extended texts on assembly quote line
        // [SCENARIO #0009] Insert extended texts for item with no extended texts on assembly quote line
        // [SCENARIO #0021] Insert extended texts twice for item with extended texts on assembly quote line
        // [SCENARIO #0013] Insert extended texts for item with extended texts on blanket assembly order line
        // [SCENARIO #0014] Insert extended texts for item with no extended texts on blanket assembly order line
        // [SCENARIO #0023] Insert extended texts twice for item with extended texts on blanket assembly order line
        Initialize();

        AssemblyDocumentType := GetAssemblyDocumentType();
        AutomaticExtTextsEnabled := AITTestContext.GetTestSetup().Element('Automatic Ext. Texts Enabled').ValueAsBoolean();
        ExtendedTextEnabled := AITTestContext.GetTestSetup().Element('Extended Text Enabled').ValueAsBoolean();
        TargettedNoOfExtendedTextLines := AITTestContext.GetTestSetup().Element('Targetted No. of Extended Text Lines').ValueAsInteger();
        CreatedNoOfExtendedTextLines := AITTestContext.GetExpectedData().Element('Created No. of Extended Text Lines').ValueAsInteger();

        // [GIVEN] Item with "Automatic Ext. Texts" disabled and extended text enabled for assembly document
        ItemNo := CreateItemWithExtendedText(AutomaticExtTextsEnabled, AssemblyDocumentType, ExtendedTextEnabled);
        // [GIVEN] Assembly document with item line
        AssemblyDocNo := CreateAssemblyDocumentWithItemLine(AssemblyDocumentType, ItemNo);

        // [WHEN] Insert extended text
        InsertExtendedText(AssemblyDocumentType, AssemblyDocNo, ItemNo);

        if CreatedNoOfExtendedTextLines <> 0 then
            // [THEN] Extended text lines are added to assembly document
            VerifyExtendedTextLinesAreAddedToAssemblyDocument(AssemblyDocumentType, AssemblyDocNo, ItemNo, CreatedNoOfExtendedTextLines)
        else
            // [THEN] No extended text lines are added to assembly document
            VerifyNoExtendedTextLinesAreAddedToAssemblyDocument(AssemblyDocumentType, AssemblyDocNo);

        if TargettedNoOfExtendedTextLines <> CreatedNoOfExtendedTextLines then begin
            // [WHEN] Insert extended text
            InsertExtendedText(AssemblyDocumentType, AssemblyDocNo, ItemNo);

            // [THEN] No additional extended text lines are added to assembly document
            VerifyNoAdditionalExtendedTextLinesAreAddedToAssemblyDocument(AssemblyDocumentType, AssemblyDocNo, ItemNo, CreatedNoOfExtendedTextLines);
        end;
    end;

    var
        LibraryExtTextAssDoc: Codeunit "Library - Ext Text Ass Doc FLX";
        AITTestContext: Codeunit "AIT Test Context";
        IsInitialized: Boolean;

    local procedure Initialize()
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize FLX";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Ext. Text Ins. Item AD DDT FLX");

        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Ext. Text Ins. Item AD DDT FLX");

        // [GIVEN] Set Nos on assembly setup
        SetNosOnAssemblySetup();

        IsInitialized := true;
        Commit();

        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Ext. Text Ins. Item AD DDT FLX");
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

    local procedure CreateItemWithExtendedText(AutomaticExtTextsEnabled: Boolean; AssemblyDocumentType: Enum "Assembly Document Type"; ExtendedTextEnabled: Boolean): Code[20]
    begin
        exit(LibraryExtTextAssDoc.CreateItemWithExtendedText(AutomaticExtTextsEnabled, AssemblyDocumentType, ExtendedTextEnabled));
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

    local procedure VerifyNoExtendedTextLinesAreAddedToAssemblyDocument(AssemblyDocumentType: Enum "Assembly Document Type"; AssemblyDocNo: Code[20])
    begin
        LibraryExtTextAssDoc.VerifyNoExtendedTextLinesAreAddedToAssemblyDocument(AssemblyDocumentType, AssemblyDocNo);
    end;

    local procedure VerifyNoAdditionalExtendedTextLinesAreAddedToAssemblyDocument(AssemblyDocumentType: Enum "Assembly Document Type"; AssemblyDocNo: Code[20]; ItemNo: Code[20]; CreatedNoOfExtendedTextLines: Integer)
    begin
        VerifyExtendedTextLinesAreAddedToAssemblyDocument(AssemblyDocumentType, AssemblyDocNo, ItemNo, CreatedNoOfExtendedTextLines);
    end;

    local procedure GetAssemblyDocumentType(): Enum "Assembly Document Type"
    var
        AssemblyDocumentType: Text;
    begin
        exit(LibraryExtTextAssDoc.GetAssemblyDocumentType());
    end;
}