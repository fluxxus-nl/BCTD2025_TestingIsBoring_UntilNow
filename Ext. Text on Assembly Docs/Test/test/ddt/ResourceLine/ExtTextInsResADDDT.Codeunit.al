codeunit 76465 "Ext. Text Ins. Res. AD DDT FLX"
{
    // Generated on 2025-06-07 by lvanvugt

    Subtype = Test;

    trigger OnRun()
    begin
        // [FEATURE] Extended Text for insert resource line on assembly document
    end;

    [Test]
    procedure InsertExtendedTextsForResourceOnAssemblyDocument()
    // [FEATURE] Extended Text on assembly document/Add resource line
    var
        AssemblyDocumentType: Enum "Assembly Document Type";
        AutomaticExtTextsEnabled, ExtendedTextEnabled : Boolean;
        CreatedNoOfExtendedTextLines, TargettedNoOfExtendedTextLines : Integer;
        AssemblyDocNo: Code[20];
        ResourceNo: Code[20];
    begin
        // [SCENARIO #0027] Insert extended texts for resource with extended texts on assembly order line
        // [SCENARIO #0028] Insert extended texts for resource with no extended texts on assembly order line
        // [SCENARIO #0029] Insert extended texts twice for resource with extended texts on assembly order line
        // [SCENARIO #0034] Insert extended texts for resource with extended texts on assembly quote line
        // [SCENARIO #0035] Insert extended texts for resource with no extended texts on assembly quote line
        // [SCENARIO #0036] Insert extended texts twice for resource with extended texts on assembly quote line
        // [SCENARIO #0041] Insert extended texts for resource with extended texts on blanket blanket assembly order line
        // [SCENARIO #0042] Insert extended texts for resource with no extended texts on blanket blanket assembly order line
        // [SCENARIO #0043] Insert extended texts twice for resource with extended texts on blanket blanket assembly order line
        Initialize();

        AssemblyDocumentType := GetAssemblyDocumentType();
        AutomaticExtTextsEnabled := AITTestContext.GetTestSetup().Element('Automatic Ext. Texts Enabled').ValueAsBoolean();
        ExtendedTextEnabled := AITTestContext.GetTestSetup().Element('Extended Text Enabled').ValueAsBoolean();
        TargettedNoOfExtendedTextLines := AITTestContext.GetTestSetup().Element('Targetted No. of Extended Text Lines').ValueAsInteger();
        CreatedNoOfExtendedTextLines := AITTestContext.GetExpectedData().Element('Created No. of Extended Text Lines').ValueAsInteger();

        // [GIVEN] Resource with "Automatic Ext. Texts" disabled and extended text enabled for assembly document
        ResourceNo := CreateResourceWithExtendedText(AutomaticExtTextsEnabled, AssemblyDocumentType, ExtendedTextEnabled);
        // [GIVEN] Assembly document with resource line
        AssemblyDocNo := CreateAssemblyDocumentWithResourceLine(AssemblyDocumentType, ResourceNo);

        // [WHEN] Insert extended text
        InsertExtendedText(AssemblyDocumentType, AssemblyDocNo, ResourceNo);

        if CreatedNoOfExtendedTextLines <> 0 then
            // [THEN] Extended text lines are added to assembly document
            VerifyExtendedTextLinesAreAddedToAssemblyDocument(AssemblyDocumentType, AssemblyDocNo, ResourceNo, CreatedNoOfExtendedTextLines)
        else
            // [THEN] No extended text lines are added to assembly document
            VerifyNoExtendedTextLinesAreAddedToAssemblyDocument(AssemblyDocumentType, AssemblyDocNo);

        if TargettedNoOfExtendedTextLines <> CreatedNoOfExtendedTextLines then begin
            // [WHEN] Insert extended text
            InsertExtendedText(AssemblyDocumentType, AssemblyDocNo, ResourceNo);

            // [THEN] No additional extended text lines are added to assembly document
            VerifyNoAdditionalExtendedTextLinesAreAddedToAssemblyDocument(AssemblyDocumentType, AssemblyDocNo, ResourceNo, CreatedNoOfExtendedTextLines);
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
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Ext. Text Ins. Res. AD DDT FLX");

        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Ext. Text Ins. Res. AD DDT FLX");

        // [GIVEN] Set Nos on assembly setup
        SetNosOnAssemblySetup();

        IsInitialized := true;
        Commit();

        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Ext. Text Ins. Res. AD DDT FLX");
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

    local procedure CreateResourceWithExtendedText(AutomaticExtTextsEnabled: Boolean; AssemblyDocumentType: Enum "Assembly Document Type"; ExtendedTextEnabled: Boolean): Code[20]
    begin
        exit(LibraryExtTextAssDoc.CreateResourceWithExtendedText(AutomaticExtTextsEnabled, AssemblyDocumentType, ExtendedTextEnabled));
    end;

    local procedure InsertExtendedText(AssemblyDocumentType: Enum "Assembly Document Type"; AssemblyDocNo: Code[20]; ResourceNo: Code[20])
    var
        AssemblyLine: Record "Assembly Line";
    begin
        LibraryExtTextAssDoc.InsertExtendedText(AssemblyDocumentType, AssemblyDocNo, AssemblyLine.Type::Resource, ResourceNo);
    end;

    local procedure VerifyExtendedTextLinesAreAddedToAssemblyDocument(AssemblyDocumentType: Enum "Assembly Document Type"; AssemblyDocNo: Code[20]; ResourceNo: Code[20]; CreatedNoOfExtendedTextLines: Integer)
    var
        AssemblyLine: Record "Assembly Line";
    begin
        LibraryExtTextAssDoc.VerifyExtendedTextLinesAreAddedToAssemblyDocument(AssemblyDocumentType, AssemblyDocNo, AssemblyLine.Type::Resource, ResourceNo, 1);
    end;

    local procedure VerifyNoExtendedTextLinesAreAddedToAssemblyDocument(AssemblyDocumentType: Enum "Assembly Document Type"; AssemblyDocNo: Code[20])
    begin
        LibraryExtTextAssDoc.VerifyNoExtendedTextLinesAreAddedToAssemblyDocument(AssemblyDocumentType, AssemblyDocNo);
    end;

    local procedure VerifyNoAdditionalExtendedTextLinesAreAddedToAssemblyDocument(AssemblyDocumentType: Enum "Assembly Document Type"; AssemblyDocNo: Code[20]; ResourceNo: Code[20]; CreatedNoOfExtendedTextLines: Integer)
    begin
        VerifyExtendedTextLinesAreAddedToAssemblyDocument(AssemblyDocumentType, AssemblyDocNo, ResourceNo, CreatedNoOfExtendedTextLines);
    end;

    local procedure GetAssemblyDocumentType(): Enum "Assembly Document Type"
    var
        AssemblyDocumentType: Text;
    begin
        exit(LibraryExtTextAssDoc.GetAssemblyDocumentType());
    end;
}