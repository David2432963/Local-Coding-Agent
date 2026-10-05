# Local Coding Agent

A local MCP server that lets an AI coding client work with a folder on your
computer. It includes a local dashboard and can connect to ChatGPT Web through
the OpenAI tunnel client.

> **Security:** The agent can read and change files in the configured workspace
> and may run commands. Only connect workspaces you trust. This is not an
> operating-system sandbox.

## Requirements

- Node.js 18 or newer.
- The OpenAI tunnel client, obtained separately. It is not included in this
  repository. On Windows, place it at `tools/tunnel-client.exe`; on macOS/Linux,
  place it at `tools/tunnel-client`.
- .NET 10 SDK only if you want to build the optional Windows tray app.

## Quick start

### Windows

If you have not downloaded the repository yet:

```powershell
git clone https://github.com/David2432963/Local-Coding-Agent.git
cd Local-Coding-Agent
```

Then run `install.bat` once, edit `setup.json` in the repository root, and run
`start-server.bat`.

To stop the server and tunnel, run `stop-server.bat`.

### macOS and Linux

```bash
git clone https://github.com/David2432963/Local-Coding-Agent.git
cd Local-Coding-Agent
bash install.sh
```

Edit `setup.json`, then start the server and tunnel:

```bash
bash scripts/lca start
```

Stop them with:

```bash
bash scripts/lca stop
```

The installers create `setup.json` if it is missing and install the server
dependencies. They do not install Node.js or download the tunnel client.

## Configure `setup.json`

Set these values before starting:

| Field | What to enter |
|---|---|
| `workspace` | Absolute path to the folder the agent may access, for example `C:/Users/Alex/Projects/MyApp`. |
| `mode` | `safe` (recommended) or `full`. |
| `policy` | `balanced` (recommended), `strict`, or `full`. |
| `tunnelId` | The Tunnel ID from your OpenAI tunnel setup. |
| `organizationId` | Optional. Add it only if your tunnel setup requires it. |
| `runtimeKey` | Your Runtime API key for the tunnel. |

The JSON has a `_comments` section with these notes. JSON does not support
`//` comments, so keep notes inside `_comments` to avoid making the file invalid.
The local `setup.json` is ignored by Git because it can contain credentials.
Do not commit or share it. A fresh clone creates a new file when you run the
installer; copy settings to another computer privately if needed.

The tunnel client must be placed in the `tools/` path above. For a standard
setup, no custom tunnel executable path is needed in `setup.json`.

## Start and connect

The MCP server listens at `http://127.0.0.1:8787/mcp`; the dashboard is at
`http://127.0.0.1:8790/ui`. Check server health at
`http://127.0.0.1:8787/healthz`.

To connect ChatGPT Web, open **Settings → Connectors**, enable Developer mode,
and add a custom MCP connector using the tunnel URL shown by the launcher.

## Modes and policies

- `mode: safe` applies stricter command restrictions. `full` allows broader
  command use. Neither mode is an operating-system sandbox.
- `policy: strict` is read-only. `balanced` asks for local approval for risky
  actions such as deleting files, installing packages, network access, or
  changing Git state. `full` removes that policy approval step.
- Recommended starting values: `safe` mode and `balanced` policy.

## Troubleshooting

| Problem | What to check |
|---|---|
| `node` is not found | Install Node.js 18+ and reopen the terminal. |
| Server dependencies are missing | Run `install.bat` or `bash install.sh`. |
| Tunnel client is not found | Put the client in the correct `tools/` path above. |
| Runtime key or Tunnel ID is missing | Check `runtimeKey` and `tunnelId` in `setup.json`. |
| Dashboard does not open | Check `http://127.0.0.1:8787/healthz` and review the server logs. |
| Organization is required | Add `organizationId` to `setup.json` and enter the organization that owns the tunnel. |
| Wrong folder is accessible | Check `workspace` in `setup.json`; verify the active path with `workspace_info`. |

For network problems, see [docs/NETWORK_DOCTOR.md](docs/NETWORK_DOCTOR.md).
For AI-agent install and update instructions, see
[docs/AI_AGENT_SETUP_PROMPT.md](docs/AI_AGENT_SETUP_PROMPT.md) and
[docs/CUSTOMER_UPDATE_PROMPT.md](docs/CUSTOMER_UPDATE_PROMPT.md).

## Development

Run the server test suite from `server/`:

```bash
npm run test:agent
```

See [SECURITY.md](SECURITY.md) before connecting a new or untrusted workspace.
This project is licensed under [AGPL-3.0-or-later](LICENSE).

---

## Tiếng Việt

Local Coding Agent là MCP server chạy trên máy của bạn, cho phép AI coding
client làm việc trong thư mục đã chọn. Dự án có dashboard nội bộ và có thể kết
nối ChatGPT Web qua tunnel client của OpenAI.

> **Bảo mật:** Agent có thể đọc, sửa file trong workspace và chạy lệnh. Chỉ kết
> nối workspace bạn tin cậy. Đây không phải sandbox của hệ điều hành.

### Yêu cầu

- Node.js 18 trở lên.
- OpenAI tunnel client, bạn cần tự lấy vì repo không kèm file này. Windows đặt
  tại `tools/tunnel-client.exe`; macOS/Linux đặt tại `tools/tunnel-client`.
- Chỉ cần .NET 10 SDK nếu muốn build Windows tray app tùy chọn.

### Cài và chạy trên Windows

Nếu chưa tải repo về máy:

```powershell
git clone https://github.com/David2432963/Local-Coding-Agent.git
cd Local-Coding-Agent
```

Sau đó chạy `install.bat` một lần, sửa `setup.json` ở thư mục gốc repo rồi chạy
`start-server.bat`.

Dừng server và tunnel bằng `stop-server.bat`.

### Cài và chạy trên macOS/Linux

```bash
git clone https://github.com/David2432963/Local-Coding-Agent.git
cd Local-Coding-Agent
bash install.sh
```

Sửa `setup.json`, rồi chạy:

```bash
bash scripts/lca start
```

Dừng bằng:

```bash
bash scripts/lca stop
```

Installer tạo `setup.json` nếu chưa có và cài dependencies cho server. Nó
không cài Node.js và không tải tunnel client.

### Cấu hình `setup.json`

Điền các giá trị sau trước khi chạy:

| Trường | Giá trị cần nhập |
|---|---|
| `workspace` | Đường dẫn tuyệt đối đến thư mục agent được phép truy cập, ví dụ `C:/Users/Alex/Projects/MyApp`. |
| `mode` | `safe` (khuyên dùng) hoặc `full`. |
| `policy` | `balanced` (khuyên dùng), `strict` hoặc `full`. |
| `tunnelId` | Tunnel ID trong phần thiết lập OpenAI tunnel. |
| `organizationId` | Không bắt buộc. Chỉ thêm nếu tunnel yêu cầu. |
| `runtimeKey` | Runtime API key dùng cho tunnel. |

Phần `_comments` trong JSON có ghi chú cho từng trường. JSON không hỗ trợ
comment dạng `//`; hãy giữ ghi chú trong `_comments` để file không bị lỗi.
`setup.json` bị Git bỏ qua vì có thể chứa thông tin bí mật. Không commit hoặc
chia sẻ file này. Khi clone repo trên máy mới, chạy installer để tạo file rồi
chuyển cấu hình sang máy đó bằng cách riêng tư.

Tunnel client phải được đặt đúng đường dẫn trong `tools/` như phía trên. Với
cấu hình thông thường, không cần khai báo đường dẫn riêng trong `setup.json`.

### Kiểm tra và kết nối ChatGPT

MCP server dùng địa chỉ `http://127.0.0.1:8787/mcp`; dashboard ở
`http://127.0.0.1:8790/ui`. Kiểm tra server tại
`http://127.0.0.1:8787/healthz`.

Để kết nối ChatGPT Web, mở **Settings → Connectors**, bật Developer mode và thêm
custom MCP connector bằng tunnel URL mà launcher hiển thị.

### Mode và policy

- `mode: safe` giới hạn lệnh chặt hơn; `full` cho phép dùng nhiều lệnh hơn. Cả
  hai đều không phải sandbox của hệ điều hành.
- `policy: strict` chỉ đọc. `balanced` yêu cầu duyệt local cho thao tác rủi ro
  như xóa file, cài package, truy cập mạng hoặc thay đổi Git. `full` bỏ bước
  duyệt theo policy.
- Nên bắt đầu với `safe` và `balanced`.

### Khắc phục lỗi thường gặp

| Lỗi | Cần kiểm tra |
|---|---|
| Không tìm thấy `node` | Cài Node.js 18+ rồi mở lại terminal. |
| Thiếu dependencies server | Chạy `install.bat` hoặc `bash install.sh`. |
| Không tìm thấy tunnel client | Đặt client đúng đường dẫn trong `tools/`. |
| Thiếu Runtime key hoặc Tunnel ID | Kiểm tra `runtimeKey` và `tunnelId` trong `setup.json`. |
| Dashboard không mở | Kiểm tra `http://127.0.0.1:8787/healthz` và log server. |
| Tunnel yêu cầu Organization ID | Thêm `organizationId` vào `setup.json` và nhập đúng organization sở hữu tunnel. |
| Agent truy cập nhầm thư mục | Kiểm tra `workspace`; dùng `workspace_info` để xem đường dẫn đang hoạt động. |

Nếu gặp lỗi mạng, xem [docs/NETWORK_DOCTOR.md](docs/NETWORK_DOCTOR.md).
Hướng dẫn cho AI agent nằm tại [docs/AI_AGENT_SETUP_PROMPT.md](docs/AI_AGENT_SETUP_PROMPT.md)
và [docs/CUSTOMER_UPDATE_PROMPT.md](docs/CUSTOMER_UPDATE_PROMPT.md).

### Phát triển

Chạy test server trong thư mục `server/`:

```bash
npm run test:agent
```

Đọc [SECURITY.md](SECURITY.md) trước khi kết nối workspace lạ. Dự án dùng giấy
phép [AGPL-3.0-or-later](LICENSE).
