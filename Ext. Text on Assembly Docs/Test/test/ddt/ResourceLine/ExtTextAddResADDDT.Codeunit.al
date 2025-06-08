codeunit 76462 "Ext. Text Add. Res. AD DDT FLX"
{
    // Generated on 2025-06-07 by lvanvugt

    Subtype = Test;

    trigger OnRun()
    begin
        // [FEATURE] Extended Text for added resource line on assembly document
    end;

    [Test]
    procedure AddToAssemblyOrderLineForResourceWithAutomaticExtTextsDisabledAndExtendedTextEnabled()
    // [FEATURE] Extended Text on assembly document/Add resource line
    var
        AssemblyDocumentType: Enum "Assembly Document Type";
        AutomaticExtTextsEnabled, ExtendedTextEnabled : Boolean;
        CreatedNoOfExtendedTextLines: Integer;
        AssemblyDocNo: Code[20];
        ResourceNo: Code[20];
    begin
        // [SCENARIO #0025] Add to assembly order line for resource with "Automatic Ext. Texts" disabled and extended text enabled
        // [SCENARIO #0026] Add to assembly order line for resource with "Automatic Ext. Texts" enabled and extended text enabled
        // [SCENARIO #0070] Add to assembly order line for resource with "Automatic Ext. Texts" enabled and extended text disabled
        // [SCENARIO #0032] Add to assembly quote line for resource with "Automatic Ext. Texts" disabled and extended text enabled
        // [SCENARIO #0033] Add to assembly quote line for resource with "Automatic Ext. Texts" enabled and extended text enabled
        // [SCENARIO #0071] Add to assembly quote line for resource with "Automatic Ext. Texts" enabled and extended text disabled
        // [SCENARIO #0039] Add to blanket blanket assembly order line for resource with "Automatic Ext. Texts" disabled and extended text enabled
        // [SCENARIO #0040] Add to blanket blanket assembly order line for resource with "Automatic Ext. Texts" enabled and extended text enabled
        // [SCENARIO #0072] Add to blanket blanket assembly order line for resource with "Automatic Ext. Texts" enabled and extended text disabled
        Initialize();

        AssemblyDocumentType := GetAssemblyDocumentType();
        AutomaticExtTextsEnabled := AITTestContext.GetTestSetup().Element('Automatic Ext. Texts Enabled').ValueAsBoolean();
        ExtendedTextEnabled := AITTestContext.GetTestSetup().Element('Extended Text Enabled').ValueAsBoolean();
        CreatedNoOfExtendedTextLines := AITTestContext.GetExpectedData().Element('Created No. of Extended Text Lines').ValueAsInteger();

        // [GIVEN] Resource with "Automatic Ext. Texts" disabled and extended text enabled for assembly document
        ResourceNo := CreateResourceWithExtendedText(AutomaticExtTextsEnabled, AssemblyDocumentType, ExtendedTextEnabled);
        // [GIVEN] Assembly document
        AssemblyDocNo := CreateAssemblyDocument(AssemblyDocumentType);

        // [WHEN] Add resource line to assembly document page
        AddResourceLineToAssemblyOrderPage(AssemblyDocumentType, AssemblyDocNo, ResourceNo);

        if CreatedNoOfExtendedTextLines <> 0 then
            // [THEN] Extended text lines are added to assembly document
            VerifyExtendedTextLinesAreAddedToAssemblyDocument(AssemblyDocumentType, AssemblyDocNo, ResourceNo)
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
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Ext. Text Add. Res. AD DDT FLX");

        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Ext. Text Add. Res. AD DDT FLX");

        // [GIVEN] Set Nos on assembly setup
        SetNosOnAssemblySetup();

        IsInitialized := true;
        Commit();

        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Ext. Text Add. Res. AD DDT FLX");
    end;

    local procedure SetNosOnAssemblySetup()
    begin
        LibraryExtTextAssDoc.SetNosOnAssemblySetup();
    end;

    local procedure AddResourceLineToAssemblyOrderPage(AssemblyDocumentType: Enum "Assembly Document Type"; AssemblyDocNo: Code[20]; ResourceNo: Code[20])
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
                    AssemblyOrderPage.Lines.Type.SetValue(AssemblyLine.Type::Resource);
                    AssemblyOrderPage.Lines."No.".SetValue(ResourceNo);
                    AssemblyOrderPage.Close();
                end;
            "Assembly Document Type"::Quote:
                begin
                    AssemblyQuotePage.OpenEdit();
                    AssemblyQuotePage.GoToRecord(AssemblyHeader);
                    AssemblyQuotePage.Lines.Type.SetValue(AssemblyLine.Type::Resource);
                    AssemblyQuotePage.Lines."No.".SetValue(ResourceNo);
                    AssemblyQuotePage.Close();
                end;
            "Assembly Document Type"::"Blanket Order":
                begin
                    AssemblyBlanketOrderPage.OpenEdit();
                    AssemblyBlanketOrderPage.GoToRecord(AssemblyHeader);
                    AssemblyBlanketOrderPage.Lines.Type.SetValue(AssemblyLine.Type::Resource);
                    AssemblyBlanketOrderPage.Lines."No.".SetValue(ResourceNo);
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

    local procedure CreateResourceWithExtendedText(AutomaticExtTextsEnabled: Boolean; AssemblyDocumentType: Enum "Assembly Document Type"; ExtendedTextEnabled: Boolean): Code[20]
    begin
        exit(LibraryExtTextAssDoc.CreateResourceWithExtendedText(AutomaticExtTextsEnabled, AssemblyDocumentType, ExtendedTextEnabled));
    end;

    local procedure VerifyExtendedTextLinesAreAddedToAssemblyDocument(AssemblyDocumentType: Enum "Assembly Document Type"; AssemblyDocNo: Code[20]; ResourceNo: Code[20])
    var
        AssemblyLine: Record "Assembly Line";
    begin
        LibraryExtTextAssDoc.VerifyExtendedTextLinesAreAddedToAssemblyDocument(AssemblyDocumentType, AssemblyDocNo, AssemblyLine.Type::Resource, ResourceNo, 1);
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