codeunit 76463 "Ext. Text Ins. Text AD DDT FLX"
{
    // Generated on 2025-06-07 by lvanvugt

    Subtype = Test;

    trigger OnRun()
    begin
        // [FEATURE] Extended Text for inserted text line on assembly document
    end;

    [Test]
    procedure InsertExtendedTextsForTextWithExtendedTextsOnAssemblyDocumentLine()
    var
        AssemblyDocumentType: Enum "Assembly Document Type";
        ExtendedTextEnabled: Boolean;
        CreatedNoOfExtendedTextLines, TargettedNoOfExtendedTextLines : Integer;
        AssemblyDocNo: Code[20];
        TextCode: Code[20];
    begin
        // [SCENARIO #0048] Insert extended texts for text with extended texts on assembly order line
        // [SCENARIO #0055] Insert extended texts for text with extended texts on assembly quote line
        // [SCENARIO #0062] Insert extended texts for text with extended texts on blanket assembly order line
        // [SCENARIO #0049] Insert extended texts for text with no extended texts on assembly order line
        // [SCENARIO #0056] Insert extended texts for text with no extended texts on assembly quote line
        // [SCENARIO #0063] Insert extended texts for text with no extended texts on blanket assembly order line
        // [SCENARIO #0050] Insert extended texts twice for text with extended texts on assembly order line
        // [SCENARIO #0057] Insert extended texts twice for text with extended texts on assembly quote line
        // [SCENARIO #0064] Insert extended texts twice for text with extended texts on blanket assembly order line
        Initialize();

        AssemblyDocumentType := GetAssemblyDocumentType();
        ExtendedTextEnabled := AITTestContext.GetTestSetup().Element('Extended Text Enabled').ValueAsBoolean();
        TargettedNoOfExtendedTextLines := AITTestContext.GetTestSetup().Element('Targetted No. of Extended Text Lines').ValueAsInteger();
        CreatedNoOfExtendedTextLines := AITTestContext.GetExpectedData().Element('Created No. of Extended Text Lines').ValueAsInteger();

        // [GIVEN] Standard text with extended text disabled for assembly document
        TextCode := CreateStandardTextWithExtendedText(AssemblyDocumentType, ExtendedTextEnabled);
        // [GIVEN] Assembly document with text line
        AssemblyDocNo := CreateAssemblyDocumentWithTextLine(AssemblyDocumentType, TextCode);

        // [WHEN] Insert extended text
        InsertExtendedText(AssemblyDocumentType, AssemblyDocNo, TextCode);

        if CreatedNoOfExtendedTextLines <> 0 then
            // [THEN] Extended text lines are added to assembly document
            VerifyExtendedTextLinesAreAddedToAssemblyDocument(AssemblyDocumentType, AssemblyDocNo, TextCode, CreatedNoOfExtendedTextLines)
        else
            // [THEN] No extended text lines are added to assembly document
            VerifyNoExtendedTextLinesAreAddedToAssemblyDocument(AssemblyDocumentType, AssemblyDocNo);

        if TargettedNoOfExtendedTextLines <> CreatedNoOfExtendedTextLines then begin
            // [WHEN] Insert extended text
            InsertExtendedText(AssemblyDocumentType, AssemblyDocNo, TextCode);

            // [THEN] No additional extended text lines are added to assembly document
            VerifyNoAdditionalExtendedTextLinesAreAddedToAssemblyDocument(AssemblyDocumentType, AssemblyDocNo, TextCode, CreatedNoOfExtendedTextLines);
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
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Ext. Text Ins. Text AD DDT FLX");

        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Ext. Text Ins. Text AD DDT FLX");

        // [GIVEN] Set Nos on assembly setup
        SetNosOnAssemblySetup();

        IsInitialized := true;
        Commit();

        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Ext. Text Ins. Text AD DDT FLX");
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

    local procedure CreateStandardTextWithExtendedText(AssemblyDocumentType: Enum "Assembly Document Type"; ExtendedTextEnabled: Boolean): Code[20]
    begin
        exit(LibraryExtTextAssDoc.CreateStandardTextWithExtendedText(AssemblyDocumentType, ExtendedTextEnabled));
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

    local procedure VerifyNoAdditionalExtendedTextLinesAreAddedToAssemblyDocument(AssemblyDocumentType: Enum "Assembly Document Type"; AssemblyDocNo: Code[20]; TextCode: Code[20]; CreatedNoOfExtendedTextLines: Integer)
    begin
        VerifyExtendedTextLinesAreAddedToAssemblyDocument(AssemblyDocumentType, AssemblyDocNo, TextCode, CreatedNoOfExtendedTextLines);
    end;

    local procedure VerifyNoExtendedTextLinesAreAddedToAssemblyDocument(AssemblyDocumentType: Enum "Assembly Document Type"; AssemblyDocNo: Code[20])
    begin
        LibraryExtTextAssDoc.VerifyNoExtendedTextLinesAreAddedToAssemblyDocument(AssemblyDocumentType, AssemblyDocNo);
    end;

    local procedure GetAssemblyDocumentType(): Enum "Assembly Document Type"
    var
        AssemblyDocumentType: Text;
    begin
        exit(LibraryExtTextAssDoc.GetAssemblyDocumentType());
    end;
}