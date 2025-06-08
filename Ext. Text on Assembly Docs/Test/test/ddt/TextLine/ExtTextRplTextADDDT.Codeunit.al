codeunit 76466 "Ext. Text Rpl. Text AD DDT FLX"
{
    // Generated on 2025-06-07 by lvanvugt

    Subtype = Test;

    trigger OnRun()
    begin
        // [FEATURE] Extended Text for replace text line on assembly document
    end;

    [Test]
    procedure ReplaceTextWithExtendedTextsByTextWithoutExtendedTextsOnAssemblyDocumentLine()
    var
        AssemblyDocumentType: Enum "Assembly Document Type";
        ExtendedTextEnabled: Boolean;
        CreatedNoOfExtendedTextLines: Integer;
        AssemblyDocNo: Code[20];
        TextCode: array[2] of Code[20];
    begin
        // [SCENARIO #0051] Replace text with extended texts by text without extended texts on assembly document line
        // [SCENARIO #0058] Replace text with extended texts by text without extended texts on assembly quote line
        // [SCENARIO #0065] Replace text with extended texts by text without extended texts on blanket assembly order line
        Initialize();

        AssemblyDocumentType := GetAssemblyDocumentType();
        ExtendedTextEnabled := AITTestContext.GetTestSetup().Element('Extended Text Enabled').ValueAsBoolean();
        CreatedNoOfExtendedTextLines := AITTestContext.GetExpectedData().Element('Created No. of Extended Text Lines').ValueAsInteger();

        // [GIVEN] Standard text with extended text enabled for assembly document
        TextCode[1] := CreateStandardTextWithExtendedText(AssemblyDocumentType, ExtendedTextEnabled);
        // [GIVEN] Standard text with no extended text
        TextCode[2] := CreateStandardTextWithNoExtendedText();
        // [GIVEN] Assembly document with text line and extended text inserted
        AssemblyDocNo := CreateAssemblyDocumentWithTextLineAndExtendedTextInserted(AssemblyDocumentType, TextCode[1]);

        // [WHEN] Replace text by text with no extended text
        ReplaceTextByTextWithNoExtendedTextOnAssemblyDocumentPage(AssemblyDocumentType, AssemblyDocNo, TextCode);

        // [THEN] Text is replaced and extended text lines are removed
        VerifyTextIsReplacedAndExtendedTextLinesAreRemoved(AssemblyDocumentType, AssemblyDocNo, TextCode);
    end;

    var
        LibraryExtTextAssDoc: Codeunit "Library - Ext Text Ass Doc FLX";
        AITTestContext: Codeunit "AIT Test Context";
        IsInitialized: Boolean;

    local procedure Initialize()
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize FLX";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Ext. Text Rpl. Text AD DDT FLX");

        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Ext. Text Rpl. Text AD DDT FLX");

        // [GIVEN] Set Nos on assembly setup
        SetNosOnAssemblySetup();

        IsInitialized := true;
        Commit();

        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Ext. Text Rpl. Text AD DDT FLX");
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

    local procedure CreateStandardTextWithNoExtendedText(): Code[20]
    begin
        exit(LibraryExtTextAssDoc.CreateStandardTextWithNoExtendedText());
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

    local procedure ReplaceTextByTextWithNoExtendedTextOnAssemblyDocumentPage(AssemblyDocumentType: Enum "Assembly Document Type"; AssemblyDocNo: Code[20]; TextCode: array[2] of Code[20])
    var
        AssemblyHeader: Record "Assembly Header";
        AssemblyLine: Record "Assembly Line";
        AssemblyOrderPage: TestPage "Assembly Order";
        AssemblyQuotePage: TestPage "Assembly Quote";
        AssemblyBlanketOrderPage: TestPage "Blanket Assembly Order";
    begin
        AssemblyHeader.Get(AssemblyDocumentType, AssemblyDocNo);

        LibraryExtTextAssDoc.FindAssemblyLine(AssemblyDocumentType, AssemblyDocNo, AssemblyLine.Type::" ", TextCode[1], AssemblyLine);

        case AssemblyDocumentType of
            "Assembly Document Type"::Order:
                begin
                    AssemblyOrderPage.OpenEdit();
                    AssemblyOrderPage.GoToRecord(AssemblyHeader);
                    AssemblyOrderPage.Lines.GoToRecord(AssemblyLine);
                    AssemblyOrderPage.Lines.Type.SetValue(AssemblyLine.Type::" ");
                    AssemblyOrderPage.Lines."No.".SetValue(TextCode[2]);
                    AssemblyOrderPage.Close();
                end;
            "Assembly Document Type"::Quote:
                begin
                    AssemblyQuotePage.OpenEdit();
                    AssemblyQuotePage.GoToRecord(AssemblyHeader);
                    AssemblyQuotePage.Lines.Type.SetValue(AssemblyLine.Type::" ");
                    AssemblyQuotePage.Lines."No.".SetValue(TextCode[2]);
                    AssemblyQuotePage.Close();
                end;
            "Assembly Document Type"::"Blanket Order":
                begin
                    AssemblyBlanketOrderPage.OpenEdit();
                    AssemblyBlanketOrderPage.GoToRecord(AssemblyHeader);
                    AssemblyBlanketOrderPage.Lines.Type.SetValue(AssemblyLine.Type::" ");
                    AssemblyBlanketOrderPage.Lines."No.".SetValue(TextCode[2]);
                    AssemblyBlanketOrderPage.Close();
                end;
            else
                LibraryExtTextAssDoc.ThrowInvalidAssemblyDocumentError(Format(AssemblyDocumentType));
        end;
    end;

    local procedure VerifyExtendedTextLinesAreAddedToAssemblyDocument(AssemblyDocumentType: Enum "Assembly Document Type"; AssemblyDocNo: Code[20]; TextCode: Code[20]; CreatedNoOfExtendedTextLines: Integer)
    var
        AssemblyLine: Record "Assembly Line";
    begin
        LibraryExtTextAssDoc.VerifyExtendedTextLinesAreAddedToAssemblyDocument(AssemblyDocumentType, AssemblyDocNo, AssemblyLine.Type::" ", TextCode, CreatedNoOfExtendedTextLines);
    end;

    local procedure VerifyTextIsReplacedAndExtendedTextLinesAreRemoved(AssemblyDocumentType: Enum "Assembly Document Type"; AssemblyDocNo: Code[20]; TextCode: array[2] of Code[20])
    var
        AssemblyLine: Record "Assembly Line";
    begin
        LibraryExtTextAssDoc.VerifyReplacementAndExtendedTextLinesAreRemoved(AssemblyDocumentType, AssemblyDocNo, AssemblyLine.Type::" ", TextCode);
    end;

    local procedure GetAssemblyDocumentType(): Enum "Assembly Document Type"
    var
        AssemblyDocumentType: Text;
    begin
        exit(LibraryExtTextAssDoc.GetAssemblyDocumentType());
    end;
}