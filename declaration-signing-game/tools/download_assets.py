#!/usr/bin/env python3
"""
Historical Asset Downloader for Declaration of Independence Game
Downloads public domain historical materials from LoC, NARA, NPS, and Wikimedia
Updates SourceLog.json with download information and sources
"""

import os
import json
import requests
import hashlib
import time
from pathlib import Path
from typing import Dict, List, Optional
from urllib.parse import urlparse, urljoin
from dataclasses import dataclass

@dataclass
class AssetDownload:
    """Represents a historical asset to download"""
    id: str
    name: str
    url: str
    description: str
    source_org: str
    asset_type: str  # 'map', 'portrait', 'document', 'building'
    target_path: str
    metadata: Dict
    
class HistoricalAssetDownloader:
    """Downloads and manages historical assets for the game"""
    
    def __init__(self, project_root: str):
        self.project_root = Path(project_root)
        self.assets_dir = self.project_root / "assets"
        self.source_log_path = self.project_root / "data" / "SourceLog.json"
        self.download_log_path = self.project_root / "tools" / "download_log.json"
        
        # Create asset directories
        self.create_asset_directories()
        
        # Load existing source log
        self.source_log = self.load_source_log()
        
        # Asset catalog
        self.asset_catalog = self.build_asset_catalog()
        
    def create_asset_directories(self):
        """Create all necessary asset directories"""
        dirs = [
            "assets/maps",
            "assets/interiors", 
            "assets/portraits",
            "assets/audio/music",
            "assets/audio/sfx", 
            "assets/audio/vo",
            "tools"
        ]
        
        for dir_path in dirs:
            (self.project_root / dir_path).mkdir(parents=True, exist_ok=True)
            
    def load_source_log(self) -> Dict:
        """Load existing SourceLog.json"""
        try:
            with open(self.source_log_path, 'r', encoding='utf-8') as f:
                return json.load(f)
        except FileNotFoundError:
            return {"sources": {}, "downloads": {}}
            
    def save_source_log(self):
        """Save updated SourceLog.json"""
        with open(self.source_log_path, 'w', encoding='utf-8') as f:
            json.dump(self.source_log, f, indent=2, ensure_ascii=False)
            
    def build_asset_catalog(self) -> List[AssetDownload]:
        """Build catalog of assets to download"""
        return [
            # Philadelphia Maps
            AssetDownload(
                id="philly_map_1752",
                name="Plan of Philadelphia 1752",
                url="https://www.loc.gov/resource/g3824p.pm008500/",
                description="Nicholas Scull map of Philadelphia showing street grid",
                source_org="Library of Congress",
                asset_type="map",
                target_path="assets/maps/philadelphia_1752.jpg",
                metadata={
                    "year": 1752,
                    "cartographer": "Nicholas Scull",
                    "scale": "Historical reference",
                    "coverage": "Philadelphia street grid"
                }
            ),
            AssetDownload(
                id="philly_map_1777",
                name="Plan of Philadelphia 1777",
                url="https://www.loc.gov/resource/g3824p.ar133800/",
                description="Revolutionary War era Philadelphia map",
                source_org="Library of Congress",
                asset_type="map", 
                target_path="assets/maps/philadelphia_1777.jpg",
                metadata={
                    "year": 1777,
                    "coverage": "Philadelphia during Revolutionary War",
                    "relevance": "Post-Declaration street layout"
                }
            ),
            
            # Independence Hall HABS Drawings
            AssetDownload(
                id="independence_hall_exterior",
                name="Independence Hall Exterior - HABS",
                url="https://www.loc.gov/resource/hhh.pa1186.sheet.00001a/",
                description="Historic American Buildings Survey exterior view",
                source_org="Library of Congress - HABS", 
                asset_type="building",
                target_path="assets/interiors/independence_hall_exterior.jpg",
                metadata={
                    "survey": "HABS PA-1186",
                    "building": "Independence Hall",
                    "view": "South facade"
                }
            ),
            AssetDownload(
                id="assembly_room_interior",
                name="Assembly Room Interior - HABS",
                url="https://www.loc.gov/resource/hhh.pa1186.sheet.00005a/",
                description="HABS documentation of Assembly Room interior",
                source_org="Library of Congress - HABS",
                asset_type="building",
                target_path="assets/interiors/assembly_room_interior.jpg", 
                metadata={
                    "survey": "HABS PA-1186", 
                    "room": "Assembly Room",
                    "details": "Historical furnishing arrangement"
                }
            ),
            
            # Portraits from Wikimedia Commons (Public Domain)
            AssetDownload(
                id="jefferson_portrait",
                name="Thomas Jefferson Portrait by Rembrandt Peale",
                url="https://upload.wikimedia.org/wikipedia/commons/1/1e/Thomas_Jefferson_by_Rembrandt_Peale%2C_1800.jpg",
                description="1800 portrait by Rembrandt Peale",
                source_org="Wikimedia Commons",
                asset_type="portrait",
                target_path="assets/portraits/jefferson.jpg",
                metadata={
                    "subject": "Thomas Jefferson",
                    "artist": "Rembrandt Peale", 
                    "year": 1800,
                    "license": "Public Domain"
                }
            ),
            AssetDownload(
                id="adams_portrait", 
                name="John Adams Portrait by Gilbert Stuart",
                url="https://upload.wikimedia.org/wikipedia/commons/d/d4/John_Adams_A18236.jpg",
                description="Portrait by Gilbert Stuart, c. 1800-1815",
                source_org="Wikimedia Commons",
                asset_type="portrait",
                target_path="assets/portraits/adams.jpg",
                metadata={
                    "subject": "John Adams",
                    "artist": "Gilbert Stuart",
                    "year": "c. 1800-1815",
                    "license": "Public Domain" 
                }
            ),
            AssetDownload(
                id="franklin_portrait",
                name="Benjamin Franklin Portrait by Joseph Duplessis", 
                url="https://upload.wikimedia.org/wikipedia/commons/6/68/BenFranklinDuplessis.jpg",
                description="1778 portrait by Joseph Duplessis",
                source_org="Wikimedia Commons",
                asset_type="portrait",
                target_path="assets/portraits/franklin.jpg",
                metadata={
                    "subject": "Benjamin Franklin",
                    "artist": "Joseph Duplessis", 
                    "year": 1778,
                    "license": "Public Domain"
                }
            ),
            AssetDownload(
                id="hancock_portrait",
                name="John Hancock Portrait by John Singleton Copley",
                url="https://upload.wikimedia.org/wikipedia/commons/3/3e/JohnHancockLarge.jpg",
                description="c. 1770-1772 portrait by Copley", 
                source_org="Wikimedia Commons",
                asset_type="portrait",
                target_path="assets/portraits/hancock.jpg",
                metadata={
                    "subject": "John Hancock",
                    "artist": "John Singleton Copley",
                    "year": "c. 1770-1772",
                    "license": "Public Domain"
                }
            ),
            AssetDownload(
                id="washington_portrait",
                name="George Washington Portrait by Gilbert Stuart",
                url="https://upload.wikimedia.org/wikipedia/commons/b/b6/Gilbert_Stuart_Williamstown_Portrait_of_George_Washington.jpg",
                description="The Gibbs-Channing-Avery Portrait, 1797",
                source_org="Wikimedia Commons", 
                asset_type="portrait",
                target_path="assets/portraits/washington.jpg",
                metadata={
                    "subject": "George Washington",
                    "artist": "Gilbert Stuart",
                    "year": 1797,
                    "license": "Public Domain"
                }
            ),
            
            # Historical Documents
            AssetDownload(
                id="dunlap_broadside_image",
                name="Dunlap Broadside - Library of Congress",
                url="https://tile.loc.gov/image-services/iiif/service:rbc:rbpe:rbpe02:rbpe021/rbpe0210/full/pct:100/0/default.jpg",
                description="First printing of Declaration, July 4-5, 1776",
                source_org="Library of Congress",
                asset_type="document",
                target_path="assets/documents/dunlap_broadside.jpg",
                metadata={
                    "document": "Declaration of Independence - First Printing",
                    "printer": "John Dunlap",
                    "date": "July 4-5, 1776",
                    "significance": "First copies distributed to public"
                }
            ),
            
            # Colonial Interior Elements
            AssetDownload(
                id="windsor_chair_reference",
                name="Colonial Windsor Chair Reference",
                url="https://upload.wikimedia.org/wikipedia/commons/8/84/Windsor_chair_MET_DP105080.jpg", 
                description="Period Windsor chair from Metropolitan Museum",
                source_org="Wikimedia Commons - Met Museum",
                asset_type="interior",
                target_path="assets/interiors/windsor_chair.jpg",
                metadata={
                    "object": "Windsor Chair",
                    "period": "18th century American",
                    "museum": "Metropolitan Museum of Art",
                    "license": "Public Domain"
                }
            )
        ]
        
    def download_asset(self, asset: AssetDownload) -> bool:
        """Download a single asset"""
        try:
            print(f"Downloading {asset.name}...")
            
            # Check if already downloaded
            target_path = self.project_root / asset.target_path
            if target_path.exists():
                print(f"  Already exists: {asset.target_path}")
                return True
                
            # Create directory if needed
            target_path.parent.mkdir(parents=True, exist_ok=True)
            
            # Download with headers
            headers = {
                'User-Agent': 'Historical Game Asset Downloader - Educational Use'
            }
            
            response = requests.get(asset.url, headers=headers, timeout=30)
            response.raise_for_status()
            
            # Save file
            with open(target_path, 'wb') as f:
                f.write(response.content)
                
            # Calculate hash
            hash_md5 = hashlib.md5()
            with open(target_path, 'rb') as f:
                for chunk in iter(lambda: f.read(4096), b""):
                    hash_md5.update(chunk)
                    
            # Update source log
            self.source_log["downloads"][asset.id] = {
                "asset_id": asset.id,
                "name": asset.name,
                "url": asset.url,
                "local_path": asset.target_path,
                "source_org": asset.source_org,
                "description": asset.description,
                "asset_type": asset.asset_type,
                "metadata": asset.metadata,
                "downloaded_at": time.strftime("%Y-%m-%d %H:%M:%S"),
                "file_hash": hash_md5.hexdigest(),
                "file_size": target_path.stat().st_size
            }
            
            print(f"  Downloaded: {asset.target_path}")
            return True
            
        except Exception as e:
            print(f"  Error downloading {asset.name}: {str(e)}")
            return False
            
    def download_all_assets(self) -> Dict[str, bool]:
        """Download all assets in catalog"""
        results = {}
        
        print("Starting historical asset download...")
        print(f"Target directory: {self.assets_dir}")
        print(f"Total assets: {len(self.asset_catalog)}")
        print("-" * 60)
        
        for asset in self.asset_catalog:
            results[asset.id] = self.download_asset(asset)
            time.sleep(1)  # Be respectful to servers
            
        # Save updated source log
        self.save_source_log()
        
        # Generate download report
        self.generate_download_report(results)
        
        return results
        
    def generate_download_report(self, results: Dict[str, bool]):
        """Generate download report"""
        successful = sum(1 for success in results.values() if success)
        total = len(results)
        
        report = {
            "download_session": {
                "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
                "total_assets": total,
                "successful_downloads": successful,
                "failed_downloads": total - successful,
                "success_rate": f"{successful/total*100:.1f}%"
            },
            "asset_results": results,
            "asset_summary_by_type": {}
        }
        
        # Group by asset type
        for asset in self.asset_catalog:
            asset_type = asset.asset_type
            if asset_type not in report["asset_summary_by_type"]:
                report["asset_summary_by_type"][asset_type] = {
                    "total": 0,
                    "successful": 0,
                    "assets": []
                }
            
            report["asset_summary_by_type"][asset_type]["total"] += 1
            report["asset_summary_by_type"][asset_type]["assets"].append(asset.id)
            
            if results.get(asset.id, False):
                report["asset_summary_by_type"][asset_type]["successful"] += 1
                
        # Save report
        with open(self.download_log_path, 'w', encoding='utf-8') as f:
            json.dump(report, f, indent=2, ensure_ascii=False)
            
        # Print summary
        print("-" * 60)
        print("DOWNLOAD COMPLETE")
        print(f"Successful: {successful}/{total} ({successful/total*100:.1f}%)")
        print(f"Report saved: {self.download_log_path}")
        print(f"Source log updated: {self.source_log_path}")
        
        # Print by type
        print("\nAssets by Type:")
        for asset_type, info in report["asset_summary_by_type"].items():
            print(f"  {asset_type.title()}: {info['successful']}/{info['total']}")
            
    def verify_asset_integrity(self) -> Dict[str, bool]:
        """Verify downloaded assets exist and are valid"""
        results = {}
        
        print("Verifying asset integrity...")
        
        for asset_id, download_info in self.source_log.get("downloads", {}).items():
            local_path = self.project_root / download_info["local_path"]
            
            if not local_path.exists():
                print(f"  Missing: {download_info['name']}")
                results[asset_id] = False
                continue
                
            # Verify file size
            expected_size = download_info.get("file_size", 0)
            actual_size = local_path.stat().st_size
            
            if expected_size > 0 and actual_size != expected_size:
                print(f"  Size mismatch: {download_info['name']}")
                results[asset_id] = False
                continue
                
            results[asset_id] = True
            
        verified = sum(1 for valid in results.values() if valid)
        total = len(results)
        
        print(f"Asset verification: {verified}/{total} valid")
        return results
        
def main():
    """Main entry point"""
    import argparse
    
    parser = argparse.ArgumentParser(description="Download historical assets for Declaration game")
    parser.add_argument("--project-root", default=".", help="Project root directory")
    parser.add_argument("--verify-only", action="store_true", help="Only verify existing assets")
    parser.add_argument("--asset-type", help="Download only specific asset type")
    
    args = parser.parse_args()
    
    downloader = HistoricalAssetDownloader(args.project_root)
    
    if args.verify_only:
        downloader.verify_asset_integrity()
    else:
        if args.asset_type:
            # Filter by asset type
            filtered_catalog = [
                asset for asset in downloader.asset_catalog 
                if asset.asset_type == args.asset_type
            ]
            downloader.asset_catalog = filtered_catalog
            
        downloader.download_all_assets()
        
if __name__ == "__main__":
    main()