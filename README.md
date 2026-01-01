#  PROJECT — End-to-End CI/CD Pipeline with Docker + AWS

## 🚀 Overview
**What this proves:** You understand real DevOps workflows, can explain CI/CD, and can deploy safely and repeatedly using GitHub Actions, Docker, Terraform, and AWS.

## 🎯 Tech Stack
- **CI/CD:** GitHub Actions
- **Container:** Docker
- **Cloud:** AWS EC2 (Free tier)
- **Web server:** Nginx
- **Provisioning:** Terraform (basic)
- **OS:** Linux (Ubuntu)

---

## 📦 Project Description (CV / GitHub)
Designed and implemented a CI/CD pipeline that builds, tests, containerizes, and deploys a web application to AWS EC2 using GitHub Actions and Docker, with infrastructure provisioned via Terraform.

---

## 🏗️ Architecture
Developer → GitHub → GitHub Actions
  ↓
Docker Build → Push Image → Deploy to EC2 → Nginx

---

## 📁 Repository Structure
```
devops-cicd-aws/
├── app/                      # simple web app (static or basic app)
├── Dockerfile                # containerizes the app
├── terraform/
│   ├── main.tf               # infra: EC2, SG, keypair
│   ├── variables.tf          # optional inputs
│   └── outputs.tf            # outputs such as server_public_ip
├── .github/workflows/deploy.yml
├── nginx/                    # nginx-related files (if any)
└── README.md
```

---

## ⚙️ Quick Start
Prerequisites:
- GitHub repo and Actions enabled
- AWS Credentials stored as `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` (Repository Secrets)
- `SSH_PRIVATE_KEY` repo secret (see Notes below)

Local (build & run):
```bash
# Build locally
docker build -t devops-cicd-app:latest .
# Run locally
docker run --rm -p 8080:80 devops-cicd-app:latest
# Open http://localhost:8080
```

Deploy via GitHub Actions:
1. Push to `main` (workflow trigger)
2. GitHub Actions runs `terraform init && terraform apply` and sets `instance_ip`
3. Actions SSH into the instance and runs the Docker container (Nginx)

---

## 🔐 SSH Key / Secrets (Important)
- The workflow expects a **private key** in repo secrets named exactly: `SSH_PRIVATE_KEY`.
- If Terraform generated the key pair, run locally where your Terraform state is:
```bash
cd terraform
terraform output -raw private_ssh_key_pem > deploy_key
chmod 600 deploy_key
```
- Add the contents of `deploy_key` to GitHub Secrets (Repository → Settings → Secrets & variables → Actions → New repository secret) with name: `SSH_PRIVATE_KEY`.

Alternative: add your _public_ key to the `authorized_keys` on the instance via `user_data` and use your own private key.

---

## ✅ Useful Commands & Debugging
- Check instance public IP (from Terraform output or Actions log): `terraform output -raw server_public_ip`
- SSH locally:
```bash
ssh -i deploy_key ubuntu@<server_public_ip>
```
- Check Docker & container on instance:
```bash
sudo docker ps -a
sudo docker logs web
curl -I http://127.0.0.1
```
- Check cloud-init logs (if user_data failed):
```bash
sudo cat /var/log/cloud-init-output.log
```
- If website not reachable, ensure Security Group allows port 80 ingress and port 22 for SSH.

---

## 🧠 Interview-ready Talking Points
- Why Docker? (consistency, packaging, portability)
- How GitHub Actions works (events, jobs, steps, secrets)
- Secrets management (GitHub Secrets, keep private keys out of logs)
- Zero-downtime ideas (blue-green or rolling updates)
- Rollback strategy (tagged images, Terraform state, revert workflow runs)

---

## 💡 Tips & Next Steps
- Pin action versions in workflows for stability (avoid `@master`).
- Protect secrets and rotate keys regularly.
- Consider adding health checks, monitoring, and auto-replace strategies (blue/green or canary deploys).

---

If you want, I can add a short `USAGE.md` with exact commands for retrieving the Terraform-generated key and creating the GitHub secret using the `gh` CLI. ✅
