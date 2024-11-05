report 90320 "Customer Balance"
{
    DefaultLayout = RDLC;
    RDLCLayout = './SM_13_CustomerBalance.rdl';
    Caption = 'Тооцоо нийлсэн акт';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Customer; "Customer")
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.";
            RequestFilterHeading = 'Customer';
            column(CustomerNo; "No.")
            {
            }
            column(CompanyName; CompanyInfo.Name)
            {
            }
            column(CompanyAddress; CompanyInfo.Address)
            {
            }
            column(CompanyInfoPhoneNo; CompanyInfo."Phone No.")
            {
            }
            column(CompanyInfoEmail; CompanyInfo."E-Mail")
            {
            }
            column(CompanyInfoBankName; CompanyInfo."Bank Name")
            {
            }
            column(CompanyInfoBankAccountNo; CompanyInfo."Bank Account No.")
            {
            }
            column(CompanyInfoVATRegNo; CompanyInfo."VAT Registration No.")
            {
            }
            column("CustomerName"; Name)
            {
            }
            column("CustomerAddress"; "Address")
            {
            }

            column("CustomerPhone"; "Phone No.")
            {
            }
            column("CustomerEmail"; "E-Mail")
            {
            }

            column("CompanyEmpPosition"; "CompanyEmpPosition")
            {
            }
            column("CompanyEmpName"; "CompanyEmpName")
            {
            }
            column("CustomerEmpPosition"; "CustomerEmpPosition")
            {
            }
            column("CustomerEmpFirstName"; "CustomerEmpFirstName")
            {
            }
            column("CustomerEmpLastName"; "CustomerEmpLastName")
            {
            }
            column("StartYear"; "StartYear")
            {
            }
            column("StartMonth"; "StartMonth")
            {
            }
            column("StartDay"; "StartDay")
            {
            }

            column("EndYear"; "EndYear")
            {
            }
            column("EndMonth"; "EndMonth")
            {
            }
            column("EndDay"; "EndDay")
            {
            }
            column("TotalAmount"; "TotalAmount")
            {
            }
            column("AmountText"; "AmountText")
            {
            }
            column("PaymentType"; "PaymentType")
            {
            }
            column("CompanyLogo"; "CompanyInfo".Picture)
            {
            }
            column(County; Customer.County)
            {
            }
            trigger OnAfterGetRecord()
            begin
                Customer.SetRange("Date Filter", 0D, EndDate);
                Customer.CalcFields("Net Change (LCY)");
                AmountText := LocalisationMgt.Amount2Text('', Customer."Net Change (LCY)");
                TotalAmount := Customer."Net Change (LCY)";

                StartYear := Format(Date2DMY(StartDate, 3));
                StartMonth := Format(Date2DMY(StartDate, 2));
                StartDay := Format(Date2DMY(StartDate, 1));

                EndYear := Format(Date2DMY(EndDate, 3));
                EndMonth := Format(Date2DMY(EndDate, 2));
                EndDay := Format(Date2DMY(EndDate, 1));
            end;

            trigger OnPostDataItem()
            begin

            end;

            trigger OnPreDataItem()
            begin

            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field("Эхлэх огноо"; "StartDate")
                    {
                        ApplicationArea = All;
                    }
                    field("Дуусах огноо"; "EndDate")
                    {
                        ApplicationArea = All;
                    }
                    field("Ажилтны албан тушаал"; "CompanyEmpPosition")
                    {
                        ApplicationArea = All;
                    }
                    field("Ажилтны нэр"; "CompanyEmpName")
                    {
                        ApplicationArea = All;
                    }
                    field("Харилцагч: Ажилтны албан тушаал"; CustomerEmpPosition)
                    {
                        ApplicationArea = All;
                    }
                    field("Харилцагч: Ажилтны овог"; CustomerEmpLastName)
                    {
                        ApplicationArea = All;
                    }
                    field("Харилцагч: Ажилтны нэр"; CustomerEmpFirstName)
                    {
                        ApplicationArea = All;
                    }
                    field("Тооцооны хэлбэр"; PaymentType)
                    {
                        ApplicationArea = All;
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnInit()
        begin
            CompanyInfo.Get;
            TotalAmount := 0;
        end;

        trigger OnOpenPage()
        var
            StdReportWithCaption: Record AllObjWithCaption;
            ReportManagementCodeunit: Codeunit ReportManagement;
        begin

        end;
    }

    labels
    {
    }

    trigger OnInitReport()
    begin

    end;

    trigger OnPostReport()
    begin

    end;

    trigger OnPreReport()
    begin
        CompanyInfo.CalcFields(Picture);
    end;

    var
        TotalAmount: Decimal;
        AmountText: Text;
        CompanyInfo: Record "Company Information";
        LocalisationMgt: Codeunit "SM_13 Localisation Management";
        StartDate: Date;
        EndDate: Date;
        CompanyEmpPosition: Text;
        CustomerEmpPosition: Text;
        CompanyEmpName: Text;
        CustomerEmpFirstName: Text;
        CustomerEmpLastName: Text;

        StartYear: Text;
        StartMonth: Text;
        StartDay: Text;
        EndYear: Text;
        EndMonth: Text;
        EndDay: Text;
        PaymentType: Text;
}

