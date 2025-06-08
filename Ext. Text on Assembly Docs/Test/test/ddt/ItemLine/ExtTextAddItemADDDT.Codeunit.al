codeunit 76461 "Ext. Text Add. Item AD DDT FLX"
{
    // Generated on 2025-06-07 by lvanvugt

    Subtype = Test;

    trigger OnRun()
    begin
        // [FEATURE] Extended Text for added item line on assembly document
    end;

    [Test]
    procedure AddExtendedTextsForItemOnAssemblyDocument()
    // [FEATURE] Extended Text on assembly document/Add item line
    var
        AssemblyDocumentType: Enum "Assembly Document Type";
        AutomaticExtTextsEnabled, ExtendedTextEnabled : Boolean;
        CreatedNoOfExtendedTextLines: Integer;
        AssemblyDocNo: Code[20];
        ItemNo: Code[20];
    begin
        // [SCENARIO #0001] Add to assembly order line for item with "Automatic Ext. Texts" disabled and extended text enabled
        // [SCENARIO #0002] Add to assembly order line for item with "Automatic Ext. Texts" enabled and extended text enabled
        // [SCENARIO #0067] Add to assembly order line for item with "Automatic Ext. Texts" enabled and extended text disabled
        // [SCENARIO #0006] Add to assembly quote line for item with "Automatic Ext. Texts" disabled and extended text enabled
        // [SCENARIO #0007] Add to assembly quote line for item with "Automatic Ext. Texts" enabled and extended text enabled
        // [SCENARIO #0068] Add to assembly quote line for item with "Automatic Ext. Texts" enabled and extended text disabled
        // [SCENARIO #0011] Add to blanket assembly order line for item with "Automatic Ext. Texts" disabled and extended text enabled
        // [SCENARIO #0012] Add to blanket assembly order line for item with "Automatic Ext. Texts" enabled and extended text enabled
        // [SCENARIO #0069] Add to blanket assembly order line for item with "Automatic Ext. Texts" enabled and extended text disabled
        Initialize();

        AssemblyDocumentType := GetAssemblyDocumentType();
        AutomaticExtTextsEnabled := AITTestContext.GetTestSetup().Element('Automatic Ext. Texts Enabled').ValueAsBoolean();
        ExtendedTextEnabled := AITTestContext.GetTestSetup().Element('Extended Text Enabled').ValueAsBoolean();
        CreatedNoOfExtendedTextLines := AITTestContext.GetExpectedData().Element('Created No. of Extended Text Lines').ValueAsInteger();

        // [GIVEN] Item with "Automatic Ext. Texts" disabled and extended text enabled for assembly document
        ItemNo := CreateItemWithExtendedText(AutomaticExtTextsEnabled, AssemblyDocumentType, ExtendedTextEnabled);
        // [GIVEN] Assembly document
        AssemblyDocNo := CreateAssemblyDocument(AssemblyDocumentType);

        // [WHEN] Add item line to assembly document page
        AddItemLineToAssemblyDocumentPage(AssemblyDocumentType, AssemblyDocNo, ItemNo);

        if CreatedNoOfExtendedTextLines <> 0 then
            // [THEN] Extended text lines are added to assembly document
            VerifyExtendedTextLinesAreAddedToAssemblyDocument(AssemblyDocumentType, AssemblyDocNo, ItemNo, CreatedNoOfExtendedTextLines)
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
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Ext. Text Add. Item AD DDT FLX");

        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Ext. Text Add. Item AD DDT FLX");

        // [GIVEN] Set Nos on assembly setup
        SetNosOnAssemblySetup();

        IsInitialized := true;
        Commit();

        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Ext. Text Add. Item AD DDT FLX");
    end;

    local procedure SetNosOnAssemblySetup()
    begin
        LibraryExtTextAssDoc.SetNosOnAssemblySetup();
    end;

    local procedure AddItemLineToAssemblyDocumentPage(AssemblyDocumentType: Enum "Assembly Document Type"; AssemblyDocNo: Code[20]; ItemNo: Code[20])
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
                    AssemblyOrderPage.Lines.Type.SetValue(AssemblyLine.Type::Item);
                    AssemblyOrderPage.Lines."No.".SetValue(ItemNo);
                    AssemblyOrderPage.Close();
                end;
            "Assembly Document Type"::Quote:
                begin
                    AssemblyQuotePage.OpenEdit();
                    AssemblyQuotePage.GoToRecord(AssemblyHeader);
                    AssemblyQuotePage.Lines.Type.SetValue(AssemblyLine.Type::Item);
                    AssemblyQuotePage.Lines."No.".SetValue(ItemNo);
                    AssemblyQuotePage.Close();
                end;
            "Assembly Document Type"::"Blanket Order":
                begin
                    AssemblyBlanketOrderPage.OpenEdit();
                    AssemblyBlanketOrderPage.GoToRecord(AssemblyHeader);
                    AssemblyBlanketOrderPage.Lines.Type.SetValue(AssemblyLine.Type::Item);
                    AssemblyBlanketOrderPage.Lines."No.".SetValue(ItemNo);
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

    local procedure CreateItemWithExtendedText(AutomaticExtTextsEnabled: Boolean; AssemblyDocumentType: Enum "Assembly Document Type"; ExtendedTextEnabled: Boolean): Code[20]
    begin
        exit(LibraryExtTextAssDoc.CreateItemWithExtendedText(AutomaticExtTextsEnabled, AssemblyDocumentType, ExtendedTextEnabled));
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

    local procedure GetAssemblyDocumentType(): Enum "Assembly Document Type"
    var
        AssemblyDocumentType: Text;
    begin
        exit(LibraryExtTextAssDoc.GetAssemblyDocumentType());
    end;
}