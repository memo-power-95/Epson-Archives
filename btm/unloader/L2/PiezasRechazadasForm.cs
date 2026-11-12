using System;
using System.Collections.Generic;
using System.Drawing;
using System.Windows.Forms;
using Alpha.Classes;

namespace Alpha.FunctionForms
{
    //MOD@@ Guillermo Carrillo - Unloader B2ST17: ventana "EL MES NO DEJA PROCESAR" (GantryForm_RechazoMes.cs)
    //
    //  Muestra cada pieza que el MES no deja procesar (lugar del pallet, QR, codigo de la PCB, modelo, proceso y
    //  lo que mande el MES) y deja elegir:
    //    REINTENTAR               el "Si" del proveedor: se manda el 10701 otra vez igual.
    //    CANCELAR Y REINICIAR     el "No" del proveedor: MesCenter.StopRunning().
    //    NO REPORTAR, MANDAR A NG esas piezas no se reportan y el robot las deja en el NG buffer.
    //  Hecha solo con codigo (sin .Designer.cs ni .resx). Cerrar con la X = CANCELAR Y REINICIAR.
    public class PiezasRechazadasForm : Form
    {
        public enum Decision { Cancelar, Reintentar, MandarANg }

        public Decision Eleccion { get; private set; } = Decision.Cancelar;

        //  loteFallido: true = 70106 LOT ID FAIL (si false, es pieza de otro modelo).
        //  automatico: true = lo decidio el modo NG automatico (solo informa, sin botones).
        public PiezasRechazadasForm(bool loteFallido, List<PiezaRechazada> piezas, string textoMes, string modeloMaquina,
            bool sePuedeNg, string motivoNoNg, bool automatico, string comoVaANg)
        {
            Text = "EL MES NO DEJA PROCESAR";
            StartPosition = FormStartPosition.CenterScreen;
            TopMost = true;
            FormBorderStyle = FormBorderStyle.FixedDialog;
            MaximizeBox = false;
            MinimizeBox = false;
            ClientSize = new Size(900, 560);
            Font = new Font("Microsoft Sans Serif", 11F);

            Label titulo = new Label();
            titulo.Text = "EL MES NO DEJA PROCESAR " + (piezas != null && piezas.Count == 1 ? "ESTA PIEZA" : "ESTAS PIEZAS")
                + (loteFallido ? " (LOT ID FAIL)" : " (OTRO MODELO)");
            titulo.Font = new Font("Microsoft Sans Serif", 16F, FontStyle.Bold);
            titulo.ForeColor = Color.White;
            titulo.BackColor = Color.Firebrick;
            titulo.TextAlign = ContentAlignment.MiddleCenter;
            titulo.SetBounds(0, 0, 900, 50);
            Controls.Add(titulo);

            Label modelo = new Label();
            modelo.Text = "Modelo de la maquina: " + (modeloMaquina ?? "");
            modelo.SetBounds(12, 58, 870, 24);
            Controls.Add(modelo);

            ListView lista = new ListView();
            lista.View = View.Details;
            lista.FullRowSelect = true;
            lista.GridLines = true;
            lista.SetBounds(12, 86, 876, 220);
            lista.Columns.Add("Lugar", 60);
            lista.Columns.Add("QR del pallet", 160);
            lista.Columns.Add("Codigo PCB", 210);
            lista.Columns.Add("Modelo", 130);
            lista.Columns.Add("Proceso", 110);
            lista.Columns.Add("Motivo del MES", 190);
            if (piezas != null)
            {
                foreach (PiezaRechazada p in piezas)
                {
                    ListViewItem fila = new ListViewItem(p.Lugar > 0 ? p.Lugar.ToString() : "?");
                    fila.SubItems.Add(p.Modulo ?? "");
                    fila.SubItems.Add(!string.IsNullOrEmpty(p.CodigoLeido) ? p.CodigoLeido : (p.Lote ?? ""));
                    fila.SubItems.Add(p.Modelo ?? "");
                    fila.SubItems.Add(p.Proceso ?? "");
                    fila.SubItems.Add(p.Otros ?? "");
                    lista.Items.Add(fila);
                }
            }
            Controls.Add(lista);

            TextBox mes = new TextBox();
            mes.Multiline = true;
            mes.ReadOnly = true;
            mes.ScrollBars = ScrollBars.Vertical;
            mes.Text = "Respuesta del MES:\r\n" + (textoMes ?? "");
            mes.SetBounds(12, 312, 876, 110);
            Controls.Add(mes);

            Label nota = new Label();
            nota.Text = sePuedeNg
                ? "MANDAR A NG: esas piezas no se reportan al MES; " + (comoVaANg ?? "") + "."
                : "No se puede mandar a NG: " + (motivoNoNg ?? "") + ".";
            nota.ForeColor = sePuedeNg ? Color.Black : Color.Firebrick;
            nota.SetBounds(12, 428, 876, 44);
            Controls.Add(nota);

            Button reintentar = Boton("REINTENTAR", 12, Color.SteelBlue);
            reintentar.Click += (s, e) => { Eleccion = Decision.Reintentar; Close(); };
            Button cancelar = Boton("CANCELAR Y REINICIAR", 306, Color.DimGray);
            cancelar.Click += (s, e) => { Eleccion = Decision.Cancelar; Close(); };
            Button ng = Boton("NO REPORTAR, MANDAR A NG", 600, Color.Firebrick);
            ng.Enabled = sePuedeNg;
            ng.Click += (s, e) => { Eleccion = Decision.MandarANg; Close(); };
            if (automatico)
            {
                reintentar.Visible = false;
                ng.Visible = false;
                cancelar.Text = "ENTERADO";
                cancelar.Click += (s, e) => { Eleccion = Decision.MandarANg; };
            }
            Controls.Add(reintentar);
            Controls.Add(cancelar);
            Controls.Add(ng);
        }

        static Button Boton(string texto, int x, Color color)
        {
            Button b = new Button();
            b.Text = texto;
            b.Font = new Font("Microsoft Sans Serif", 12F, FontStyle.Bold);
            b.ForeColor = Color.White;
            b.BackColor = color;
            b.FlatStyle = FlatStyle.Flat;
            b.SetBounds(x, 484, 288, 64);
            return b;
        }
    }
}
