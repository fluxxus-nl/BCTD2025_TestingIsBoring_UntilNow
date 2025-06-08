codeunit 76467 "Ext. Text Rpl. Item AD DDT FLX"
{
    // Generated on 2025-06-07 by lvanvugt

    Subtype = Test;

    trigger OnRun()
    begin
        // [FEATURE] Extended Text for replace item line on assembly document
    end;

    [Test]
    procedure ReplaceItemWithExtendedTextsByItemWithoutExtendedTextsOnAssemblyDocument()
    var
        AssemblyDocumentType: Enum "Assembly Document Type";
        AutomaticExtTextsEnabled, ExtendedTextEnabled : Boolean;
        CreatedNoOfExtendedTextLines: Integer;
        AssemblyDocNo: Code[20];
        ItemNo: array[2] of Code[20];
    begin
        // [SCENARIO #0020] Replace item with extended texts by item without extended texts on assembly order line
        // [SCENARIO #0022] Replace item with extended texts by item without extended texts on assembly quote line
        // [SCENARIO #0024] Replace item with extended texts by item without extended texts on blanket assembly order line
        Initialize();

        AssemblyDocumentType := GetAssemblyDocumentType();
        AutomaticExtTextsEnabled := AITTestContext.GetTestSetup().Element('Automatic Ext. Texts Enabled').ValueAsBoolean();
        ExtendedTextEnabled := AITTestContext.GetTestSetup().Element('Extended Text Enabled').ValueAsBoolean();
        CreatedNoOfExtendedTextLines := AITTestContext.GetExpectedData().Element('Created No. of Extended Text Lines').ValueAsInteger();

        // [GIVEN] Item with "Automatic Ext. Texts" disabled and extended text enabled for assembly document
        ItemNo[1] := CreateItemWithExtendedText(AutomaticExtTextsEnabled, AssemblyDocumentType, ExtendedTextEnabled);
        // [GIVEN] Item with no extended text
        ItemNo[2] := CreateItemWithNoExtendedText();
        // [GIVEN] Assembly document with item line and extended text inserted
        AssemblyDocNo := CreateAssemblyDocumentWithItemLineAndExtendedTextInserted(AssemblyDocumentType, ItemNo[1]);

        // [WHEN] Replace item by item with no extended text
        ReplaceItemByItemWithNoExtendedTextOnAssemblyOrderPage(AssemblyDocumentType, AssemblyDocNo, ItemNo);

        // [THEN] Item is replaced and extended text lines are removed
        VerifyItemIsReplacedAndExtendedTextLinesAreRemoved(AssemblyDocumentType, AssemblyDocNo, ItemNo);
    end;

    var
        LibraryExtTextAssDoc: Codeunit "Library - Ext Text Ass Doc FLX";
        AITTestContext: Codeunit "AIT Test Context";
        IsInitialized: Boolean;

    local procedure Initialize()
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize FLX";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Ext. Text Rpl. Item AD DDT FLX");

        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Ext. Text Rpl. Item AD DDT FLX");

        // [GIVEN] Set Nos on assembly setup
        SetNosOnAssemblySetup();

        IsInitialized := true;
        Commit();

        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Ext. Text Rpl. Item AD DDT FLX");
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

    local procedure CreateItemWithNoExtendedText(): Code[20]
    begin
        exit(LibraryExtTextAssDoc.CreateItemWithNoExtendedText());
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

    local procedure ReplaceItemByItemWithNoExtendedTextOnAssemblyOrderPage(AssemblyDocumentType: Enum "Assembly Document Type"; AssemblyDocNo: Code[20]; ItemNo: array[2] of Code[20])
    var
        AssemblyHeader: Record "Assembly Header";
        AssemblyLine: Record "Assembly Line";
        AssemblyOrderPage: TestPage "Assembly Order";
        AssemblyQuotePage: TestPage "Assembly Quote";
        AssemblyBlanketOrderPage: TestPage "Blanket Assembly Order";
    begin
        AssemblyHeader.Get(AssemblyDocumentType, AssemblyDocNo);

        LibraryExtTextAssDoc.FindAssemblyLine(AssemblyDocumentType, AssemblyDocNo, AssemblyLine.Type::Item, ItemNo[1], AssemblyLine);

        case AssemblyDocumentType of
            "Assembly Document Type"::Order:
                begin
                    AssemblyOrderPage.OpenEdit();
                    AssemblyOrderPage.GoToRecord(AssemblyHeader);
                    AssemblyOrderPage.Lines.GoToRecord(AssemblyLine);
                    AssemblyOrderPage.Lines.Type.SetValue(AssemblyLine.Type::Item);
                    AssemblyOrderPage.Lines."No.".SetValue(ItemNo[2]);
                    AssemblyOrderPage.Close();
                end;
            "Assembly Document Type"::Quote:
                begin
                    AssemblyQuotePage.OpenEdit();
                    AssemblyQuotePage.GoToRecord(AssemblyHeader);
                    AssemblyQuotePage.Lines.Type.SetValue(AssemblyLine.Type::Item);
                    AssemblyQuotePage.Lines."No.".SetValue(ItemNo[2]);
                    AssemblyQuotePage.Close();
                end;
            "Assembly Document Type"::"Blanket Order":
                begin
                    AssemblyBlanketOrderPage.OpenEdit();
                    AssemblyBlanketOrderPage.GoToRecord(AssemblyHeader);
                    AssemblyBlanketOrderPage.Lines.Type.SetValue(AssemblyLine.Type::Item);
                    AssemblyBlanketOrderPage.Lines."No.".SetValue(ItemNo[2]);
                    AssemblyBlanketOrderPage.Close();
                end;
            else
                LibraryExtTextAssDoc.ThrowInvalidAssemblyDocumentError(Format(AssemblyDocumentType));
        end;
    end;

    local procedure VerifyItemIsReplacedAndExtendedTextLinesAreRemoved(AssemblyDocumentType: Enum "Assembly Document Type"; AssemblyDocNo: Code[20]; ItemNo: array[2] of Code[20])
    var
        AssemblyLine: Record "Assembly Line";
    begin
        LibraryExtTextAssDoc.VerifyReplacementAndExtendedTextLinesAreRemoved(AssemblyDocumentType, AssemblyDocNo, AssemblyLine.Type::Item, ItemNo);
    end;

    local procedure GetAssemblyDocumentType(): Enum "Assembly Document Type"
    var
        AssemblyDocumentType: Text;
    begin
        exit(LibraryExtTextAssDoc.GetAssemblyDocumentType());
    end;
}