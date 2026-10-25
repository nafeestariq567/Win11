using System;
using System.IO;
using System.Text;
using System.Drawing;
using System.Diagnostics;
using System.Windows.Forms;
using System.Text.RegularExpressions;
using System.Security.Cryptography;

namespace AppLocker
{
    static class Program
    {
        [STAThread]
        static void Main(string[] args)
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);

            if (args.Length == 0)
            {
                MessageBox.Show("Usage: AppLocker.exe <app-key>", "App Locker", MessageBoxButtons.OK, MessageBoxIcon.Information);
                return;
            }

            string appKey = args[0].Trim();
            string baseDir = AppDomain.CurrentDomain.BaseDirectory;
            string jsonPath = Path.Combine(baseDir, "apps", appKey + ".json");

            if (!File.Exists(jsonPath))
            {
                MessageBox.Show("Application configuration for '" + appKey + "' not found at:\n" + jsonPath, "App Locker Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            string json = File.ReadAllText(jsonPath);
            string targetPath = GetJsonValue(json, "TargetPath");
            string arguments = GetJsonValue(json, "Arguments");
            string workDir = GetJsonValue(json, "WorkingDirectory");
            string displayName = GetJsonValue(json, "DisplayName");
            if (string.IsNullOrEmpty(displayName)) displayName = appKey;

            string configDir = Path.Combine(baseDir, "config");
            string hashPath = Path.Combine(configDir, "master.hash");

            if (!File.Exists(hashPath))
            {
                using (var setupForm = new SetMasterPasswordForm(hashPath, configDir))
                {
                    if (setupForm.ShowDialog() != DialogResult.OK)
                    {
                        return;
                    }
                }
            }
            else
            {
                string hashLine = File.ReadAllText(hashPath).Trim();
                string[] parts = hashLine.Split(':');
                if (parts.Length != 2)
                {
                    MessageBox.Show("Master password file is corrupted. Please run Reset-Password.cmd.", "App Locker Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return;
                }

                byte[] salt = HexToBytes(parts[0]);
                string storedHash = parts[1];

                using (var unlockForm = new UnlockForm(displayName, targetPath, salt, storedHash))
                {
                    if (unlockForm.ShowDialog() != DialogResult.OK)
                    {
                        return;
                    }
                }
            }

            // Launch target application
            try
            {
                var psi = new ProcessStartInfo();
                psi.FileName = targetPath;
                if (!string.IsNullOrEmpty(arguments)) psi.Arguments = arguments;
                if (!string.IsNullOrEmpty(workDir) && Directory.Exists(workDir))
                {
                    psi.WorkingDirectory = workDir;
                }
                else if (!string.IsNullOrEmpty(targetPath))
                {
                    psi.WorkingDirectory = Path.GetDirectoryName(targetPath);
                }
                Process.Start(psi);
            }
            catch (Exception ex)
            {
                MessageBox.Show("Failed to launch " + displayName + ":\n" + ex.Message, "App Locker Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        public static string GetJsonValue(string json, string key)
        {
            var match = Regex.Match(json, "\"" + key + "\"\\s*:\\s*\"((?:\\\\\"|[^\"])*)\"");
            if (match.Success)
            {
                return match.Groups[1].Value.Replace("\\\"", "\"").Replace("\\\\", "\\");
            }
            return "";
        }

        public static string ComputeSaltedHash(string password, byte[] salt)
        {
            using (var sha = new SHA256Managed())
            {
                byte[] pwdBytes = Encoding.UTF8.GetBytes(password);
                byte[] combined = new byte[salt.Length + pwdBytes.Length];
                Buffer.BlockCopy(salt, 0, combined, 0, salt.Length);
                Buffer.BlockCopy(pwdBytes, 0, combined, salt.Length, pwdBytes.Length);
                byte[] hashBytes = sha.ComputeHash(combined);
                StringBuilder sb = new StringBuilder();
                foreach (byte b in hashBytes) sb.Append(b.ToString("x2"));
                return sb.ToString();
            }
        }

        public static byte[] HexToBytes(string hex)
        {
            byte[] bytes = new byte[hex.Length / 2];
            for (int i = 0; i < hex.Length; i += 2)
            {
                bytes[i / 2] = Convert.ToByte(hex.Substring(i, 2), 16);
            }
            return bytes;
        }

        public static byte[] GenerateSalt(int size = 16)
        {
            byte[] salt = new byte[size];
            using (var rng = new RNGCryptoServiceProvider())
            {
                rng.GetBytes(salt);
            }
            return salt;
        }
    }

    public class SetMasterPasswordForm : Form
    {
        private TextBox txtP1;
        private TextBox txtP2;
        private Label lblErr;
        private string hashPath;
        private string configDir;

        public SetMasterPasswordForm(string hashPath, string configDir)
        {
            this.hashPath = hashPath;
            this.configDir = configDir;

            this.Text = "App Locker - Set Master Password";
            this.Size = new Size(420, 290);
            this.StartPosition = FormStartPosition.CenterScreen;
            this.FormBorderStyle = FormBorderStyle.FixedDialog;
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.TopMost = true;
            this.ShowInTaskbar = true;
            this.BackColor = Color.FromArgb(32, 32, 32);
            this.ForeColor = Color.White;

            Font fontRegular = new Font("Segoe UI", 9.5f);
            Font fontBold = new Font("Segoe UI", 11f, FontStyle.Bold);
            Font fontSmall = new Font("Segoe UI", 8.5f);

            Label lblTitle = new Label {
                Text = "Create Your Master Password",
                Font = fontBold,
                ForeColor = Color.FromArgb(240, 240, 240),
                Location = new Point(20, 15),
                Size = new Size(360, 25)
            };
            this.Controls.Add(lblTitle);

            Label lblSubtitle = new Label {
                Text = "This master password protects all locked apps on your PC.",
                Font = fontSmall,
                ForeColor = Color.FromArgb(180, 180, 180),
                Location = new Point(20, 42),
                Size = new Size(360, 20)
            };
            this.Controls.Add(lblSubtitle);

            Label lblP1 = new Label {
                Text = "Master Password:",
                Font = fontRegular,
                Location = new Point(20, 70),
                Size = new Size(360, 20)
            };
            this.Controls.Add(lblP1);

            txtP1 = new TextBox {
                Font = fontRegular,
                UseSystemPasswordChar = true,
                BackColor = Color.FromArgb(45, 45, 45),
                ForeColor = Color.White,
                BorderStyle = BorderStyle.FixedSingle,
                Location = new Point(20, 92),
                Size = new Size(360, 26)
            };
            this.Controls.Add(txtP1);

            Label lblP2 = new Label {
                Text = "Confirm Master Password:",
                Font = fontRegular,
                Location = new Point(20, 125),
                Size = new Size(360, 20)
            };
            this.Controls.Add(lblP2);

            txtP2 = new TextBox {
                Font = fontRegular,
                UseSystemPasswordChar = true,
                BackColor = Color.FromArgb(45, 45, 45),
                ForeColor = Color.White,
                BorderStyle = BorderStyle.FixedSingle,
                Location = new Point(20, 147),
                Size = new Size(360, 26)
            };
            this.Controls.Add(txtP2);

            lblErr = new Label {
                Font = fontSmall,
                ForeColor = Color.FromArgb(255, 100, 100),
                Location = new Point(20, 178),
                Size = new Size(360, 20)
            };
            this.Controls.Add(lblErr);

            Button btnSave = new Button {
                Text = "Save & Unlock",
                Font = fontRegular,
                BackColor = Color.FromArgb(0, 120, 215),
                ForeColor = Color.White,
                FlatStyle = FlatStyle.Flat,
                Location = new Point(155, 205),
                Size = new Size(120, 32)
            };
            btnSave.FlatAppearance.BorderSize = 0;
            btnSave.Click += BtnSave_Click;
            this.Controls.Add(btnSave);

            Button btnCancel = new Button {
                Text = "Cancel",
                Font = fontRegular,
                BackColor = Color.FromArgb(50, 50, 50),
                ForeColor = Color.White,
                FlatStyle = FlatStyle.Flat,
                Location = new Point(285, 205),
                Size = new Size(95, 32)
            };
            btnCancel.FlatAppearance.BorderSize = 0;
            btnCancel.Click += (s, e) => { this.DialogResult = DialogResult.Cancel; this.Close(); };
            this.Controls.Add(btnCancel);

            this.AcceptButton = btnSave;
            this.CancelButton = btnCancel;

            this.Shown += (s, e) => {
                this.Activate();
                this.BringToFront();
                txtP1.Focus();
            };
        }

        private void BtnSave_Click(object sender, EventArgs e)
        {
            string p1 = txtP1.Text;
            string p2 = txtP2.Text;

            if (string.IsNullOrWhiteSpace(p1))
            {
                lblErr.Text = "Password cannot be empty.";
                return;
            }
            if (p1.Length < 4)
            {
                lblErr.Text = "Password must be at least 4 characters.";
                return;
            }
            if (p1 != p2)
            {
                lblErr.Text = "Passwords do not match.";
                return;
            }

            byte[] salt = Program.GenerateSalt(16);
            string hexSalt = BitConverter.ToString(salt).Replace("-", "").ToLower();
            string hash = Program.ComputeSaltedHash(p1, salt);

            if (!Directory.Exists(configDir))
            {
                Directory.CreateDirectory(configDir);
            }
            File.WriteAllText(hashPath, hexSalt + ":" + hash);

            this.DialogResult = DialogResult.OK;
            this.Close();
        }
    }

    public class UnlockForm : Form
    {
        private TextBox txtPwd;
        private Label lblErr;
        private byte[] salt;
        private string storedHash;
        private int attempts = 0;

        public UnlockForm(string displayName, string targetPath, byte[] salt, string storedHash)
        {
            this.salt = salt;
            this.storedHash = storedHash;

            this.Text = "App Locker - " + displayName;
            this.Size = new Size(380, 230);
            this.StartPosition = FormStartPosition.CenterScreen;
            this.FormBorderStyle = FormBorderStyle.FixedDialog;
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.TopMost = true;
            this.ShowInTaskbar = true;
            this.BackColor = Color.FromArgb(30, 30, 30);
            this.ForeColor = Color.White;

            try
            {
                if (File.Exists(targetPath))
                {
                    Icon icon = Icon.ExtractAssociatedIcon(targetPath);
                    if (icon != null) this.Icon = icon;
                }
            }
            catch { }

            Font fontRegular = new Font("Segoe UI", 9.5f);
            Font fontBold = new Font("Segoe UI", 11f, FontStyle.Bold);
            Font fontSmall = new Font("Segoe UI", 8.5f);

            Label lblTitle = new Label {
                Text = "Locked: " + displayName,
                Font = fontBold,
                ForeColor = Color.FromArgb(240, 240, 240),
                Location = new Point(20, 18),
                Size = new Size(325, 25)
            };
            this.Controls.Add(lblTitle);

            Label lblSubtitle = new Label {
                Text = "Enter master password to unlock application:",
                Font = fontSmall,
                ForeColor = Color.FromArgb(180, 180, 180),
                Location = new Point(20, 45),
                Size = new Size(325, 20)
            };
            this.Controls.Add(lblSubtitle);

            txtPwd = new TextBox {
                Font = new Font("Segoe UI", 10.5f),
                UseSystemPasswordChar = true,
                BackColor = Color.FromArgb(45, 45, 45),
                ForeColor = Color.White,
                BorderStyle = BorderStyle.FixedSingle,
                Location = new Point(20, 72),
                Size = new Size(325, 28)
            };
            this.Controls.Add(txtPwd);

            lblErr = new Label {
                Font = fontSmall,
                ForeColor = Color.FromArgb(255, 100, 100),
                Location = new Point(20, 105),
                Size = new Size(325, 20)
            };
            this.Controls.Add(lblErr);

            Button btnUnlock = new Button {
                Text = "Unlock",
                Font = fontRegular,
                BackColor = Color.FromArgb(0, 120, 215),
                ForeColor = Color.White,
                FlatStyle = FlatStyle.Flat,
                Location = new Point(145, 135),
                Size = new Size(100, 32)
            };
            btnUnlock.FlatAppearance.BorderSize = 0;
            btnUnlock.Click += BtnUnlock_Click;
            this.Controls.Add(btnUnlock);

            Button btnCancel = new Button {
                Text = "Cancel",
                Font = fontRegular,
                BackColor = Color.FromArgb(50, 50, 50),
                ForeColor = Color.White,
                FlatStyle = FlatStyle.Flat,
                Location = new Point(255, 135),
                Size = new Size(90, 32)
            };
            btnCancel.FlatAppearance.BorderSize = 0;
            btnCancel.Click += (s, e) => { this.DialogResult = DialogResult.Cancel; this.Close(); };
            this.Controls.Add(btnCancel);

            this.AcceptButton = btnUnlock;
            this.CancelButton = btnCancel;

            this.Shown += (s, e) => {
                this.Activate();
                this.BringToFront();
                txtPwd.Focus();
            };
        }

        private void BtnUnlock_Click(object sender, EventArgs e)
        {
            string computed = Program.ComputeSaltedHash(txtPwd.Text, salt);
            if (string.Equals(computed, storedHash, StringComparison.OrdinalIgnoreCase))
            {
                this.DialogResult = DialogResult.OK;
                this.Close();
            }
            else
            {
                attempts++;
                if (attempts >= 5)
                {
                    MessageBox.Show("Too many failed unlock attempts. Application will not start.", "App Locker", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    this.DialogResult = DialogResult.Cancel;
                    this.Close();
                    return;
                }
                lblErr.Text = "Incorrect password (" + attempts + "/5). Try again.";
                txtPwd.Text = "";
                txtPwd.Focus();
            }
        }
    }
}
