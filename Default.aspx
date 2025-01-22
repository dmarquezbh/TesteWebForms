<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="TesteWebforms.Default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <title>Teste WebForms</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .grid-container { margin: 20px 0; }
        .message { padding: 10px; margin: 10px 0; }
        .success { background-color: #dff0d8; border: 1px solid #d6e9c6; }
        .error { background-color: #f2dede; border: 1px solid #ebccd1; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <h2>Teste de WebForms</h2>
            
            <div>
                <asp:Label ID="lblName" runat="server" Text="Nome:" AssociatedControlID="txtName" />
                <asp:TextBox ID="txtName" runat="server" />
                <asp:Button ID="btnAdd" runat="server" Text="Adicionar" OnClick="btnAdd_Click" />
            </div>

            <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="message">
                <asp:Literal ID="litMessage" runat="server" />
            </asp:Panel>

            <div class="grid-container">
                <asp:GridView ID="gvPessoas" runat="server" 
                    AutoGenerateColumns="false" 
                    OnRowCommand="gvPessoas_RowCommand"
                    CssClass="grid"
                    AlternatingRowStyle-BackColor="#f5f5f5">
                    <Columns>
                        <asp:BoundField DataField="Id" HeaderText="ID" />
                        <asp:BoundField DataField="Nome" HeaderText="Nome" />
                        <asp:BoundField DataField="DataCadastro" HeaderText="Data Cadastro" DataFormatString="{0:dd/MM/yyyy HH:mm}" />
                        <asp:TemplateField HeaderText="Ações">
                            <ItemTemplate>
                                <asp:LinkButton ID="lnkRemover" runat="server" 
                                    Text="Remover" 
                                    CommandName="RemoverItem"
                                    CommandArgument='<%# Eval("Id") %>'
                                    OnClientClick="return confirm('Deseja realmente remover este item?');" />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>

            <div>
                <asp:Label ID="lblDateTime" runat="server" />
                <asp:Timer ID="tmrDateTime" runat="server" Interval="1000" OnTick="tmrDateTime_Tick" />
                <asp:ScriptManager ID="ScriptManager1" runat="server" />
                <asp:UpdatePanel ID="upDateTime" runat="server">
                    <ContentTemplate>
                        <div>Hora atual do servidor: <asp:Label ID="lblCurrentTime" runat="server" /></div>
                    </ContentTemplate>
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="tmrDateTime" EventName="Tick" />
                    </Triggers>
                </asp:UpdatePanel>
            </div>
        </div>
    </form>
</body>
</html>