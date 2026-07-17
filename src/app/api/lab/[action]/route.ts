import { NextRequest, NextResponse } from "next/server";

const WORKSPACE_URL =
  process.env.WORKSPACE_URL || "http://workspace.cks-workspace.svc.cluster.local:7681";

export async function POST(
  request: NextRequest,
  { params }: { params: { action: string } }
) {
  const { action } = params;
  const body = await request.json();
  const labNum = String(body.labNum || "01").padStart(2, "0");

  let command: string;

  switch (action) {
    case "setup":
      command = `setup-lab ${labNum}`;
      break;
    case "verify":
      command = `verify-lab ${labNum}`;
      break;
    case "cleanup":
      command = `cleanup-lab ${labNum}`;
      break;
    default:
      return NextResponse.json(
        { error: "Invalid action. Use: setup, verify, cleanup" },
        { status: 400 }
      );
  }

  try {
    // Execute command in workspace pod via ttyd API or kubectl exec
    // In production, this would exec into the workspace pod
    // For now, return the command that should be run
    return NextResponse.json({
      success: true,
      action,
      labNum,
      command,
      message: `Run in terminal: ${command}`,
    });
  } catch (error) {
    return NextResponse.json(
      { error: "Failed to execute command in workspace" },
      { status: 500 }
    );
  }
}
