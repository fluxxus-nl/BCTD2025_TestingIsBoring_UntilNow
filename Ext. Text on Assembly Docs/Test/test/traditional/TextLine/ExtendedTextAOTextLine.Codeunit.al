codeunit 76457 "Extended Text AO Text Line FLX"
{
    // Generated on 06/07/2020 at 07:31 by lvanvugt

    Subtype = Test;

    trigger OnRun()
    begin
        // [FEATURE] Extended Text on assembly order/Add text line
        // [FEATURE] Extended Text on assembly order/Delete text line
    end;

    [Test]
    procedure AddToAssemblyOrderLineForTextWithExtendedTextEnabled()
    // [FEATURE] Extended Text on assembly order/Add text line
    var
        AssemblyDocNo: Code[20];
        TextCode: Code[20];
    begin
        // [SCENARIO #0046] Add to assembly order line for text with extended text enabled
        Initialize();

        // [GIVEN] Standard text with extended text enabled for assembly order
        TextCode := CreateStandardTextWithExtendedText(GetAssemblyDocumentType(), true);
        // [GIVEN] Assembly order
        AssemblyDocNo := CreateAssemblyOrder();

        // [WHEN] Add text line to assembly order page
        AddTextLineToAssemblyOrderPage(AssemblyDocNo, TextCode);

        // [THEN] Extended text lines are added to assembly order
        VerifyExtendedTextLinesAreAddedToAssemblyOrder(AssemblyDocNo, TextCode);
    end;

    [Test]
    procedure AddToAssemblyOrderLineForTextWithExtendedTextDisabled()
    // [FEATURE] Extended Text on assembly order/Add text line
    var
        AssemblyDocNo: Code[20];
        TextCode: Code[20];
    begin
        // [SCENARIO #0073] Add to assembly order line for text with extended text disabled
        Initialize();

        // [GIVEN] Standard text with extended text disabled for assembly order
        TextCode := CreateStandardTextWithExtendedText("Assembly Document Type"::None, false);
        // [GIVEN] Assembly order
        AssemblyDocNo := CreateAssemblyOrder();

        // [WHEN] Add text line to assembly order page
        AddTextLineToAssemblyOrderPage(AssemblyDocNo, TextCode);

        // [THEN] No extended text lines are added to assembly order
        VerifyNoExtendedTextLinesAreAddedToAssemblyOrder(AssemblyDocNo);
    end;

    [Test]
    procedure InsertExtendedTextsForTextWithExtendedTextsOnAssemblyOrderLine()
    // [FEATURE] Extended Text on assembly order/Add text line
    var
        AssemblyDocNo: Code[20];
        TextCode: Code[20];
    begin
        // [SCENARIO #0048] Insert extended texts for text with extended texts on assembly order line
        Initialize();

        // [GIVEN] Standard text with extended text disabled for assembly order
        TextCode := CreateStandardTextWithExtendedText(GetAssemblyDocumentType(), true);
        // [GIVEN] Assembly order with text line
        AssemblyDocNo := CreateAssemblyOrderWithTextLine(TextCode);

        // [WHEN] Insert extended text
        InsertExtendedText(AssemblyDocNo, TextCode);

        // [THEN] Extended text lines are added to assembly order
        VerifyExtendedTextLinesAreAddedToAssemblyOrder(AssemblyDocNo, TextCode);
    end;

    [Test]
    procedure InsertExtendedTextsForTextWithNoExtendedTextsOnAssemblyOrderLine()
    // [FEATURE] Extended Text on assembly order/Add text line
    var
        AssemblyDocNo: Code[20];
        TextCode: Code[20];
    begin
        // [SCENARIO #0049] Insert extended texts for text with no extended texts on assembly order line
        Initialize();

        // [GIVEN] Standard text with extended text disabled for assembly order
        TextCode := CreateStandardTextWithExtendedText("Assembly Document Type"::None, false);
        // [GIVEN] Assembly order with text line
        AssemblyDocNo := CreateAssemblyOrderWithTextLine(TextCode);

        // [WHEN] Insert extended text
        InsertExtendedText(AssemblyDocNo, TextCode);

        // [THEN] No extended text lines are added to assembly order
        VerifyNoExtendedTextLinesAreAddedToAssemblyOrder(AssemblyDocNo);
    end;

    [Test]
    procedure InsertExtendedTextsTwiceForTextWithExtendedTextsOnAssemblyOrderLine()
    // [FEATURE] Extended Text on assembly order/Add text line
    var
        AssemblyDocNo: Code[20];
        TextCode: Code[20];
    begin
        // [SCENARIO #0050] Insert extended texts twice for text with extended texts on assembly order line
        Initialize();

        // [GIVEN] Standard text with extended text enabled for assembly order
        TextCode := CreateStandardTextWithExtendedText(GetAssemblyDocumentType(), true);
        // [GIVEN] Assembly order with text line and extended text inserted
        AssemblyDocNo := CreateAssemblyOrderWithTextLineAndExtendedTextInserted(TextCode);

        // [WHEN] Insert extended text
        InsertExtendedText(AssemblyDocNo, TextCode);

        // [THEN] No additional extended text lines are added to assembly order
        VerifyNoAdditionalExtendedTextLinesAreAddedToAssemblyOrder(AssemblyDocNo, TextCode);
    end;

    [Test]
    procedure ReplaceTextWithExtendedTextsByTextWithoutExtendedTextsOnAssemblyOrderLine()
    // [FEATURE] Extended Text on assembly order/Add text line
    var
        AssemblyDocNo: Code[20];
        TextCode: array[2] of Code[20];
    begin
        // [SCENARIO #0051] Replace text with extended texts by text without extended texts on assembly order line
        Initialize();

        // [GIVEN] Standard text with extended text enabled for assembly order
        TextCode[1] := CreateStandardTextWithExtendedText(GetAssemblyDocumentType(), true);
        // [GIVEN] Standard text with no extended text
        TextCode[2] := CreateStandardTextWithNoExtendedText();
        // [GIVEN] Assembly order with text line and extended text inserted
        AssemblyDocNo := CreateAssemblyOrderWithTextLineAndExtendedTextInserted(TextCode[1]);

        // [WHEN] Replace text by text with no extended text
        ReplaceTextByTextWithNoExtendedTextOnAssemblyOrderPage(AssemblyDocNo, TextCode);

        // [THEN] Text is replaced and extended text lines are removed
        VerifyTextIsReplacedAndExtendedTextLinesAreRemoved(AssemblyDocNo, TextCode);
    end;

    [Test]
    procedure DeleteTextLineWithExtendedText()
    // [FEATURE] Extended Text on assembly order/Delete text line
    var
        AssemblyDocNo: Code[20];
        TextCode: Code[20];
    begin
        // [SCENARIO #0052] Delete text line with extended text
        Initialize();

        // [GIVEN] Standard text with extended text enabled for assembly order
        TextCode := CreateStandardTextWithExtendedText(GetAssemblyDocumentType(), true);
        // [GIVEN] Assembly order with text line and extended text inserted
        AssemblyDocNo := CreateAssemblyOrderWithTextLineAndExtendedTextInserted(TextCode);

        // [WHEN] Delete text line from assembly order
        DeleteTextLineFromAssemblyOrder(AssemblyDocNo, TextCode);

        // [THEN] Text  and extended text lines are removed
        VerifyTextAndExtendedTextLinesAreRemoved(AssemblyDocNo, TextCode);
    end;

    var
        LibraryExtTextAssDoc: Codeunit "Library - Ext Text Ass Doc FLX";
        IsInitialized: Boolean;

    local procedure Initialize()
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize FLX";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Extended Text AO Text Line FLX");

        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Extended Text AO Text Line FLX");

        // [GIVEN] Set Nos on assembly setup
        SetNosOnAssemblySetup();

        IsInitialized := true;
        Commit();

        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Extended Text AO Text Line FLX");
    end;

    local procedure SetNosOnAssemblySetup()
    begin
        LibraryExtTextAssDoc.SetNosOnAssemblySetup();
    end;

    local procedure AddTextLineToAssemblyOrderPage(AssemblyDocNo: Code[20]; TextCode: Code[20])
    var
        AssemblyHeader: Record "Assembly Header";
        AssemblyLine: Record "Assembly Line";
        AssemblyOrderPage: TestPage "Assembly Order";
    begin
        AssemblyHeader.Get(AssemblyHeader."Document Type"::Order, AssemblyDocNo);

        AssemblyOrderPage.OpenEdit();
        AssemblyOrderPage.GoToRecord(AssemblyHeader);
        AssemblyOrderPage.Lines.Type.SetValue(AssemblyLine.Type::" ");
        AssemblyOrderPage.Lines."No.".SetValue(TextCode);
        AssemblyOrderPage.Close();
    end;

    local procedure CreateAssemblyOrder(): Code[20]
    var
        AssemblyHeader: Record "Assembly Header";
    begin
        AssemblyHeader."Document Type" := AssemblyHeader."Document Type"::Order;
        AssemblyHeader.Insert(true);
        exit(AssemblyHeader."No.");
    end;

    local procedure CreateAssemblyOrderWithTextLine(TextCode: Code[20]): Code[20]
    var
        AssemblyHeader: Record "Assembly Header";
        AssemblyLine: Record "Assembly Line";
        LibraryAssembly: Codeunit "Library - Assembly 2 FLX";
    begin
        LibraryAssembly.CreateAssemblyHeader(AssemblyHeader, WorkDate(), '', '', 1, '');
        LibraryAssembly.CreateAssemblyLine(AssemblyHeader, AssemblyLine, AssemblyLine.Type::" ", TextCode, '', 0, 0, '');
        exit(AssemblyHeader."No.");
    end;

    local procedure CreateAssemblyOrderWithTextLineAndExtendedTextInserted(TextCode: Code[20]): Code[20]
    var
        AssemblyDocNo: Code[20];
    begin
        AssemblyDocNo := CreateAssemblyOrderWithTextLine(TextCode);
        InsertExtendedText(AssemblyDocNo, TextCode);
        VerifyExtendedTextLinesAreAddedToAssemblyOrder(AssemblyDocNo, TextCode);
        exit(AssemblyDocNo);
    end;

    local procedure CreateStandardTextWithNoExtendedText(): Code[20]
    begin
        exit(LibraryExtTextAssDoc.CreateStandardTextWithNoExtendedText());
    end;

    local procedure CreateStandardTextWithExtendedText(AssemblyDocumentType: Enum "Assembly Document Type"; ExtendedTextEnabled: Boolean): Code[20]
    begin
        exit(LibraryExtTextAssDoc.CreateStandardTextWithExtendedText(AssemblyDocumentType, ExtendedTextEnabled));
    end;

    local procedure DeleteTextLineFromAssemblyOrder(AssemblyDocNo: Code[20]; TextCode: Code[20])
    var
        AssemblyLine: Record "Assembly Line";
    begin
        LibraryExtTextAssDoc.DeleteLineFromAssemblyDocument(AssemblyLine."Document Type"::Order, AssemblyDocNo, AssemblyLine.Type::" ", TextCode);
    end;

    local procedure InsertExtendedText(AssemblyDocNo: Code[20]; TextCode: Code[20])
    var
        AssemblyLine: Record "Assembly Line";
    begin
        LibraryExtTextAssDoc.InsertExtendedText(AssemblyLine."Document Type"::Order, AssemblyDocNo, AssemblyLine.Type::" ", TextCode);
    end;

    local procedure ReplaceTextByTextWithNoExtendedTextOnAssemblyOrderPage(AssemblyDocNo: Code[20]; TextCode: array[2] of Code[20])
    var
        AssemblyHeader: Record "Assembly Header";
        AssemblyLine: Record "Assembly Line";
        AssemblyOrderPage: TestPage "Assembly Order";
    begin
        AssemblyHeader.Get(AssemblyHeader."Document Type"::Order, AssemblyDocNo);

        LibraryExtTextAssDoc.FindAssemblyLine(AssemblyHeader."Document Type"::Order, AssemblyDocNo, AssemblyLine.Type::" ", TextCode[1], AssemblyLine);

        AssemblyOrderPage.OpenEdit();
        AssemblyOrderPage.GoToRecord(AssemblyHeader);
        AssemblyOrderPage.Lines.GoToRecord(AssemblyLine);
        AssemblyOrderPage.Lines.Type.SetValue(AssemblyLine.Type::" ");
        AssemblyOrderPage.Lines."No.".SetValue(TextCode[2]);
        AssemblyOrderPage.Close();
    end;

    local procedure VerifyExtendedTextLinesAreAddedToAssemblyOrder(AssemblyDocNo: Code[20]; TextCode: Code[20])
    var
        AssemblyLine: Record "Assembly Line";
    begin
        LibraryExtTextAssDoc.VerifyExtendedTextLinesAreAddedToAssemblyDocument(AssemblyLine."Document Type"::Order, AssemblyDocNo, AssemblyLine.Type::" ", TextCode, 1);
    end;

    local procedure VerifyTextAndExtendedTextLinesAreRemoved(AssemblyDocNo: Code[20]; TextCode: Code[20])
    var
        AssemblyHeader: Record "Assembly Header";
    begin
        LibraryExtTextAssDoc.VerifyTextAndExtendedTextLinesAreRemoved(AssemblyHeader."Document Type"::Order, AssemblyDocNo, TextCode);
    end;

    local procedure VerifyTextIsReplacedAndExtendedTextLinesAreRemoved(AssemblyDocNo: Code[20]; TextCode: array[2] of Code[20])
    var
        AssemblyLine: Record "Assembly Line";
    begin
        LibraryExtTextAssDoc.VerifyReplacementAndExtendedTextLinesAreRemoved(AssemblyLine."Document Type"::Order, AssemblyDocNo, AssemblyLine.Type::" ", TextCode);
    end;

    local procedure VerifyNoAdditionalExtendedTextLinesAreAddedToAssemblyOrder(AssemblyDocNo: Code[20]; TextCode: Code[20])
    begin
        VerifyExtendedTextLinesAreAddedToAssemblyOrder(AssemblyDocNo, TextCode);
    end;

    local procedure VerifyNoExtendedTextLinesAreAddedToAssemblyOrder(AssemblyDocNo: Code[20])
    var
        AssemblyHeader: Record "Assembly Header";
    begin
        LibraryExtTextAssDoc.VerifyNoExtendedTextLinesAreAddedToAssemblyDocument(AssemblyHeader."Document Type"::Order, AssemblyDocNo);
    end;

    local procedure GetAssemblyDocumentType(): Enum "Assembly Document Type"
    begin
        exit("Assembly Document Type"::Order);
    end;
}