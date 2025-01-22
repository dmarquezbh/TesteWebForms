using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;

namespace TesteWebforms
{
    public partial class Default : System.Web.UI.Page
    {
        // Declaração explícita dos controles
        protected HtmlForm form1;
        protected Label lblName;
        protected TextBox txtName;
        protected Button btnAdd;
        protected Panel pnlMessage;
        protected Literal litMessage;
        protected GridView gvPessoas;
        protected Label lblDateTime;
        protected Timer tmrDateTime;
        protected ScriptManager ScriptManager1;
        protected UpdatePanel upDateTime;
        protected Label lblCurrentTime;

        private static List<Pessoa> _pessoas = new List<Pessoa>();
        private static int _nextId = 1;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (!_pessoas.Any())
                {
                    _pessoas.Add(new Pessoa { Id = _nextId++, Nome = "João Silva", DataCadastro = DateTime.Now.AddDays(-5) });
                    _pessoas.Add(new Pessoa { Id = _nextId++, Nome = "Maria Santos", DataCadastro = DateTime.Now.AddDays(-3) });
                }

                AtualizarGrid();
            }

            lblDateTime.Text = DateTime.Now.ToString("dd/MM/yyyy HH:mm:ss");
        }

        protected void btnAdd_Click(object sender, EventArgs e)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(txtName.Text))
                {
                    ShowMessage("Por favor, informe um nome...", false);
                    return;
                }

                var pessoa = new Pessoa
                {
                    Id = _nextId++,
                    Nome = txtName.Text.Trim(),
                    DataCadastro = DateTime.Now
                };

                _pessoas.Add(pessoa);
                txtName.Text = string.Empty;
                ShowMessage("Pessoa adicionada com sucesso!", true);
                AtualizarGrid();
            }
            catch (Exception ex)
            {
                ShowMessage($"Erro ao adicionar pessoa: {ex.Message}", false);
            }
        }

        protected void gvPessoas_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "RemoverItem")
            {
                try
                {
                    int id = Convert.ToInt32(e.CommandArgument);
                    var pessoa = _pessoas.FirstOrDefault(p => p.Id == id);
                    if (pessoa != null)
                    {
                        _pessoas.Remove(pessoa);
                        ShowMessage("Pessoa removida com sucesso!", true);
                        AtualizarGrid();
                    }
                }
                catch (Exception ex)
                {
                    ShowMessage($"Erro ao remover pessoa: {ex.Message}", false);
                }
            }
        }

        protected void tmrDateTime_Tick(object sender, EventArgs e)
        {
            lblCurrentTime.Text = DateTime.Now.ToString("HH:mm:ss");
        }

        private void ShowMessage(string message, bool success)
        {
            pnlMessage.Visible = true;
            pnlMessage.CssClass = $"message {(success ? "success" : "error")}";
            litMessage.Text = message;
        }

        private void AtualizarGrid()
        {
            gvPessoas.DataSource = _pessoas.OrderByDescending(p => p.DataCadastro);
            gvPessoas.DataBind();
        }
    }
}