import argparse
from pathlib import Path

class Injector:
    @staticmethod
    def inject_code(payload_path, library_path, output_filename=None):
        payload_path = Path(payload_path)
        library_path = Path(library_path)

        with open(payload_path, "r", encoding="utf-8") as f:
            payload_code = f.read()

        with open(library_path, "r", encoding="utf-8") as f:
            original_lines = f.readlines()

        injection_index = None
        for i, line in enumerate(original_lines):
            if "}());" in line:
                injection_index = i + 1
                break

        if injection_index is None:
            raise ValueError("No `}());` pattern found in the library for injection.")

        # Insert payload after the IIFE closure
        injection_block = f"\n// --- Injected Payload Start ---\n{payload_code}\n// --- Injected Payload End ---\n"
        original_lines.insert(injection_index, injection_block)

        new_filename = output_filename or f"modified_{library_path.name}"
        output_path = library_path.parent / new_filename

        with open(output_path, "w", encoding="utf-8") as f:
            f.writelines(original_lines)

        print(f"[+] Injected raw payload written to: {output_path}")

def main():
    parser = argparse.ArgumentParser(description="Inject raw JS payload into a JS library (no encoding).")
    parser.add_argument("--payload", required=True, help="Path to JavaScript payload to inject.")
    parser.add_argument("--library", required=True, help="Path to JavaScript library to modify.")
    parser.add_argument("--output", help="Optional output filename (default: dropbear_<libraryname>)")
    args = parser.parse_args()

    Injector.inject_code(args.payload, args.library, args.output)

if __name__ == "__main__":
    main()
