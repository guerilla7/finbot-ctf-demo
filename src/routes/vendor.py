from flask import Blueprint, request, jsonify, render_template
import json
from src.models.vendor import db, Vendor, Invoice
from src.services.finbot_agent import FinBotAgent
from datetime import datetime

vendor_bp = Blueprint('vendor', __name__)

# Initialize the new agent
finbot_agent = FinBotAgent()

@vendor_bp.route('/vendors', methods=['POST'])
def register_vendor():
    """Register a new vendor"""
    try:
        data = request.get_json()
        
        # Check if vendor already exists
        existing_vendor = Vendor.query.filter_by(contact_email=data['contact_email']).first()
        if existing_vendor:
            return jsonify({"error": "Vendor with this email already exists"}), 400
        
        # Create new vendor
        vendor = Vendor(
            company_name=data['company_name'],
            contact_person=data['contact_person'],
            contact_email=data['contact_email'],
            phone_number=data['phone_number'],
            business_type=data['business_type'],
            vendor_category=json.dumps(data.get('vendor_category', [])),
            tax_id=data['tax_id'],
            bank_name=data['bank_name'],
            account_holder_name=data['account_holder_name'],
            account_number=data['account_number'],
            routing_number=data['routing_number'],
            services_description=data.get('services_description', ''),
            status='approved',  # Auto-approve for demo
            trust_level='standard'
        )
        
        db.session.add(vendor)
        db.session.commit()
        
        return jsonify({
            "success": True,
            "vendor_id": vendor.id,
            "message": "Vendor registered successfully"
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500

@vendor_bp.route('/vendors/<int:vendor_id>', methods=['GET'])
def get_vendor(vendor_id):
    """Get vendor details"""
    vendor = Vendor.query.get(vendor_id)
    if not vendor:
        return jsonify({"error": "Vendor not found"}), 404
    
    return jsonify(vendor.to_dict())

@vendor_bp.route('/vendors', methods=['GET'])
def list_vendors():
    """List all vendors"""
    vendors = Vendor.query.all()
    return jsonify([vendor.to_dict() for vendor in vendors])

@vendor_bp.route('/vendors/<int:vendor_id>/invoices', methods=['POST'])
def submit_invoice(vendor_id):
    """Submit an invoice for processing"""
    try:
        vendor = Vendor.query.get(vendor_id)
        if not vendor:
            return jsonify({"error": "Vendor not found"}), 404
        
        data = request.get_json()
        
        # Check if invoice number already exists
        existing_invoice = Invoice.query.filter_by(invoice_number=data['invoice_number']).first()
        if existing_invoice:
            return jsonify({"error": "Invoice number already exists"}), 400
        
        # Parse dates
        invoice_date = datetime.strptime(data['invoice_date'], '%Y-%m-%d').date()
        due_date = datetime.strptime(data['due_date'], '%Y-%m-%d').date()
        
        # Create new invoice
        invoice = Invoice(
            vendor_id=vendor_id,
            invoice_number=data['invoice_number'],
            amount=float(data['amount']),
            description=data['description'],
            invoice_date=invoice_date,
            due_date=due_date,
            status='submitted'
        )
        
        db.session.add(invoice)
        db.session.commit()
        
        # Process with FinBot AI agent
        finbot = FinBotAgent()
        result = finbot.process_invoice(invoice.id)
        
        return jsonify({
            "success": True,
            "invoice_id": invoice.id,
            "processing_result": result
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500

@vendor_bp.route('/vendors/<int:vendor_id>/invoices', methods=['GET'])
def get_vendor_invoices(vendor_id):
    """Get all invoices for a vendor"""
    vendor = Vendor.query.get(vendor_id)
    if not vendor:
        return jsonify({"error": "Vendor not found"}), 404
    
    invoices = Invoice.query.filter_by(vendor_id=vendor_id).order_by(Invoice.created_at.desc()).all()
    return jsonify([invoice.to_dict() for invoice in invoices])

@vendor_bp.route('/invoices/<int:invoice_id>', methods=['GET'])
def get_invoice(invoice_id):
    """Get invoice details"""
    invoice = Invoice.query.get(invoice_id)
    if not invoice:
        return jsonify({"error": "Invoice not found"}), 404
    
    invoice_data = invoice.to_dict()
    vendor_data = Vendor.query.get(invoice.vendor_id).to_dict()
    
    return jsonify({
        "invoice": invoice_data,
        "vendor": vendor_data
    })

@vendor_bp.route('/invoices', methods=['GET'])
def list_invoices():
    """List all invoices with optional filtering"""
    status = request.args.get('status')
    vendor_id = request.args.get('vendor_id')
    
    query = Invoice.query
    
    if status:
        query = query.filter_by(status=status)
    if vendor_id:
        query = query.filter_by(vendor_id=vendor_id)
    
    invoices = query.order_by(Invoice.created_at.desc()).all()
    
    # Include vendor information
    result = []
    for invoice in invoices:
        invoice_data = invoice.to_dict()
        vendor = Vendor.query.get(invoice.vendor_id)
        invoice_data['vendor_name'] = vendor.company_name if vendor else 'Unknown'
        result.append(invoice_data)
    
    return jsonify(result)

