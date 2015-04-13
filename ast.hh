#ifndef AST_HH
#define AST_HH
#include <vector>


class Visitor;
class PrettyPrinter;
class Evaluator;


class Exp {
public:

	Exp() {};
	Exp(const Exp& exp) {};

	virtual ~Exp() {};
	virtual int accept(Visitor& v) const = 0;

};

class Const: public Exp {
public:

	int val_;

	Const(int val)
			: val_(val) {}

	virtual int accept(Visitor& v) const;

};

class Binop: public Exp {
public:

	char oper_;
	Exp* lhs_;
	Exp* rhs_;

	Binop(char oper, Exp* lhs, Exp* rhs)
			: Exp(), oper_(oper), lhs_(lhs), rhs_(rhs) {}

	~Binop(){
		delete lhs_;
		delete rhs_;
	}

	virtual int accept(Visitor& v) const;

};


class Driver {
public:
	std::vector<Exp*> tree;
	int count;

	Driver() {
		count = 0;
	}

	void addExp(Exp* exp) {
		tree.push_back(exp);
		count++;
	}

	Exp* makeBinop(char oper, Exp* lhs, Exp* rhs) {
		return new Binop(oper, lhs, rhs);
	}

	Exp* makeConst(int value) {
		return new Const(value);
	}

};




class Visitor {
public:

	Visitor(){};
	virtual ~Visitor(){};

	virtual int visitBinop(const Binop& exp) = 0;
	virtual int visitConst(const Const& exp) = 0;
};


class PrettyPrinter : public Visitor {
public:

	std::ostream& ostr_;

	PrettyPrinter(std::ostream& ostr)
			: ostr_(ostr) {}

	virtual int visitBinop(const Binop& e) {
		ostr_ << '(';
		e.lhs_->accept(*this);
		ostr_ << e.oper_;
		e.rhs_->accept(*this);
		ostr_ << ')';
		return 0;
	}

	virtual int visitConst(const Const& e) {
		ostr_ << e.val_;
		return 0;
	}

};


class Evaluator : public Visitor {
public:

	Evaluator() {}

	virtual int visitBinop(const Binop& e) {

		if (e.oper_ == '+')
			return e.lhs_->accept(*this) + e.rhs_->accept(*this);

		if (e.oper_ == '-')
			return e.lhs_->accept(*this) - e.rhs_->accept(*this);

		if (e.oper_ == '*')
			return e.lhs_->accept(*this) * e.rhs_->accept(*this);

		if (e.oper_ == '/') {
			int divby = e.rhs_->accept(*this);
			if (!divby) {
				return -1;
			}
			return e.lhs_->accept(*this);
		}

		return -1;
		
	}

	virtual int visitConst(const Const& e){
		return e.val_;
	}

};

inline int Const::accept(Visitor& v) const{
		return v.visitConst(*this);
}

inline int Binop::accept(Visitor& v) const{
		return v.visitBinop(*this);
}

inline std::ostream& operator<<(std::ostream& o, Exp &e){
	PrettyPrinter printer(o);
	e.accept(printer);
	return o;
}


#endif