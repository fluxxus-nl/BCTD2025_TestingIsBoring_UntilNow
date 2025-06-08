codeunit 76460 "Ext. Text Add. Text AD DDT FLX"
{
    // Generated on 2025-06-07 by lvanvugt

    Subtype = Test;

    trigger OnRun()
    begin
        // [FEATURE] Extended Text for added text line on assembly document
    end;

    [Test]
    procedure AddToAssemblyDocumentLineForText()
    // [FEATURE] Extended Text on assembly document/Add text line
    var
        AssemblyDocumentType: Enum "Assembly Document Type";
        ExtendedTextEnabled: Boolean;
        CreatedNoOfExtendedTextLines: Integer;
        AssemblyDocNo: Code[20];
        TextCode: Code[20];
    begin
        // [SCENARIO #0046] Add to assembly order line for text with extended text enabled
        // [SCENARIO #0053] Add to assembly quote line for text with extended text enabled
        // [SCENARIO #0060] Add to blanket assembly order line for text with extended text enabled
        // [SCENARIO #0073] Add to assembly order line for text with extended text disabled
        // [SCENARIO #0074] Add to assembly quote line for text with extended text disabled
        // [SCENARIO #0075] Add to blanket assembly order line for text with extended text disabled
        Initialize();

        AssemblyDocumentType := GetAssemblyDocumentType();
        ExtendedTextEnabled := AITTestContext.GetTestSetup().Element('Extended Text Enabled').ValueAsBoolean();
        CreatedNoOfExtendedTextLines := AITTestContext.GetExpectedData().Element('Created No. of Extended Text Lines').ValueAsInteger();

        // [GIVEN] Standard text with extended text enabled for assembly document
        TextCode := CreateStandardTextWithExtendedText(AssemblyDocumentType, ExtendedTextEnabled);
        // [GIVEN] Assembly document
        AssemblyDocNo := CreateAssemblyDocument(AssemblyDocumentType);

        // [WHEN] Add text line to assembly document page
        AddTextLineToAssemblyDocumentPage(AssemblyDocumentType, AssemblyDocNo, TextCode);

        if CreatedNoOfExtendedTextLines <> 0 then
            // [THEN] Extended text lines are added to assembly document
            VerifyExtendedTextLinesAreAddedToAssemblyDocument(AssemblyDocumentType, AssemblyDocNo, TextCode, CreatedNoOfExtendedTextLines)
        else
            // [THEN] No extended text lines are added to assembly document
            VerifyNoExtendedTextLinesAreAddedToAssemblyDocument(AssemblyDocumentType, AssemblyDocNo);
    end;

    var
        LibraryExtTextAssDoc: Codeunit "Library - Ext Text Ass Doc FLX";
        AITTestContext: Codeunit "AIT Test Context";
        IsInitialized: Boolean;

    local procedure Initialize()
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize FLX";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Ext. Text Add. Text AD DDT FLX");

        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Ext. Text Add. Text AD DDT FLX");

        // [GIVEN] Set Nos on assembly setup
        SetNosOnAssemblySetup();

        IsInitialized := true;
        Commit();

        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Ext. Text Add. Text AD DDT FLX");
    end;

    local procedure SetNosOnAssemblySetup()
    begin
        LibraryExtTextAssDoc.SetNosOnAssemblySetup();
    end;

    local procedure AddTextLineToAssemblyDocumentPage(AssemblyDocumentType: Enum "Assembly Document Type"; AssemblyDocNo: Code[20]; TextCode: Code[20])
    var
        AssemblyHeader: Record "Assembly Header";
        AssemblyLine: Record "Assembly Line";
        AssemblyOrderPage: TestPage "Assembly Order";
        AssemblyQuotePage: TestPage "Assembly Quote";
        AssemblyBlanketOrderPage: TestPage "Blanket Assembly Order";
    begin
        AssemblyHeader.Get(AssemblyDocumentType, AssemblyDocNo);

        case AssemblyDocumentType of
            "Assembly Document Type"::Order:
                begin
                    AssemblyOrderPage.OpenEdit();
                    AssemblyOrderPage.GoToRecord(AssemblyHeader);
                    AssemblyOrderPage.Lines.Type.SetValue(AssemblyLine.Type::" ");
                    AssemblyOrderPage.Lines."No.".SetValue(TextCode);
                    AssemblyOrderPage.Close();
                end;
            "Assembly Document Type"::Quote:
                begin
                    AssemblyQuotePage.OpenEdit();
                    AssemblyQuotePage.GoToRecord(AssemblyHeader);
                    AssemblyQuotePage.Lines.Type.SetValue(AssemblyLine.Type::" ");
                    AssemblyQuotePage.Lines."No.".SetValue(TextCode);
                    AssemblyQuotePage.Close();
                end;
            "Assembly Document Type"::"Blanket Order":
                begin
                    AssemblyBlanketOrderPage.OpenEdit();
                    AssemblyBlanketOrderPage.GoToRecord(AssemblyHeader);
                    AssemblyBlanketOrderPage.Lines.Type.SetValue(AssemblyLine.Type::" ");
                    AssemblyBlanketOrderPage.Lines."No.".SetValue(TextCode);
                    AssemblyBlanketOrderPage.Close();
                end;
            else
                LibraryExtTextAssDoc.ThrowInvalidAssemblyDocumentError(Format(AssemblyDocumentType));
        end;
    end;

    local procedure CreateAssemblyDocument(AssemblyDocumentType: Enum "Assembly Document Type"): Code[20]
    begin
        exit(LibraryExtTextAssDoc.CreateAssemblyDocument(AssemblyDocumentType));
    end;

    local procedure CreateAssemblyDocumentWithTextLine(TextCode: Code[20]): Code[20]
    var
        AssemblyHeader: Record "Assembly Header";
        AssemblyLine: Record "Assembly Line";
        LibraryAssembly: Codeunit "Library - Assembly 2 FLX";
    begin
        LibraryAssembly.CreateAssemblyHeader(AssemblyHeader, WorkDate(), '', '', 1, '');
        LibraryAssembly.CreateAssemblyLine(AssemblyHeader, AssemblyLine, AssemblyLine.Type::" ", TextCode, '', 0, 0, '');
        exit(AssemblyHeader."No.");
    end;

    local procedure CreateStandardTextWithExtendedText(AssemblyDocumentType: Enum "Assembly Document Type"; ExtendedTextEnabled: Boolean): Code[20]
    begin
        exit(LibraryExtTextAssDoc.CreateStandardTextWithExtendedText(AssemblyDocumentType, ExtendedTextEnabled));
    end;

    local procedure VerifyExtendedTextLinesAreAddedToAssemblyDocument(AssemblyDocumentType: Enum "Assembly Document Type"; AssemblyDocNo: Code[20]; TextCode: Code[20]; CreatedNoOfExtendedTextLines: Integer)
    var
        AssemblyLine: Record "Assembly Line";
    begin
        LibraryExtTextAssDoc.VerifyExtendedTextLinesAreAddedToAssemblyDocument(AssemblyDocumentType, AssemblyDocNo, AssemblyLine.Type::" ", TextCode, CreatedNoOfExtendedTextLines);
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