#!/usr/bin/env python3
"""
BookShelf - PRM393 Submission Packaging Helper
This script packages the required source files into <StudentCode>.zip adhering strictly
to the exam requirements:
- pubspec.yaml at the top level of the zip (not inside an extra folder)
- pubspec.lock
- lib/ folder
- android/ folder
- firestore.rules
- assets/ (if any)
- Excludes: build/, .dart_tool/, .git/, and checks that no admin/service-account keys are included.
"""

import os
import sys
import zipfile
import re

def package_submission(student_code: str, output_dir: str = "."):
    student_code = student_code.strip()
    if not student_code:
        print("Error: Student code cannot be empty.")
        sys.exit(1)

    zip_filename = os.path.join(output_dir, f"{student_code}.zip")
    root_dir = os.path.dirname(os.path.abspath(__file__))

    included_files = ['pubspec.yaml', 'pubspec.lock', 'firestore.rules']
    included_folders = ['lib', 'android', 'assets']

    # Security check keywords for service accounts
    forbidden_patterns = [
        re.compile(r'type["\']?\s*:\s*["\']service_account["\']', re.IGNORECASE),
        re.compile(r'private_key', re.IGNORECASE),
    ]

    print(f"--> Packaging source code for student: {student_code}")
    print(f"--> Output: {zip_filename}")

    with zipfile.ZipFile(zip_filename, 'w', zipfile.ZIP_DEFLATED) as zipf:
        # 1. Add top-level files
        for filename in included_files:
            file_path = os.path.join(root_dir, filename)
            if os.path.exists(file_path):
                zipf.write(file_path, arcname=filename)
                print(f"  + Added: {filename}")
            else:
                print(f"  ! Notice: {filename} not found.")

        # 2. Add folders
        for folder_name in included_folders:
            folder_path = os.path.join(root_dir, folder_name)
            if not os.path.exists(folder_path):
                continue

            for root, dirs, files in os.walk(folder_path):
                # Exclude cache and build folders
                dirs[:] = [d for d in dirs if d not in ['.dart_tool', 'build', '.gradle', '.idea', '.git']]
                
                for file in files:
                    # Skip unwanted files
                    if file.endswith(('.pyc', '.tmp', '.lock')) and file != 'pubspec.lock':
                        continue

                    full_path = os.path.join(root, file)
                    arcname = os.path.relpath(full_path, root_dir)

                    # Security verification
                    if file.endswith('.json'):
                        try:
                            with open(full_path, 'r', encoding='utf-8', errors='ignore') as f:
                                content = f.read()
                                for pat in forbidden_patterns:
                                    if pat.search(content):
                                        print(f"  [DANGER] Forbidden service account key detected in {arcname}!")
                                        print("  Exam rules strictly forbid submitting admin/service account keys!")
                                        sys.exit(1)
                        except Exception:
                            pass

                    zipf.write(full_path, arcname=arcname)
                    print(f"  + Added: {arcname}")

    print("\n--> Submission ZIP created successfully!")
    print(f"--> Location: {os.path.abspath(zip_filename)}")
    print(f"--> Size: {os.path.getsize(zip_filename) / 1024:.2f} KB\n")

if __name__ == '__main__':
    code = sys.argv[1] if len(sys.argv) > 1 else input("Enter your Student Code (e.g. QE200012): ")
    package_submission(code)

