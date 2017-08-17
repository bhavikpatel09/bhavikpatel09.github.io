import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { AboutComponent } from '../about/about.component'
import { PortfolioComponent } from "../portfolio/portfolio.component";
import { BlogComponent } from "../blog/blog.component";
import { ContactComponent } from "../contact/contact.component";

const routes: Routes = [
    {
        path: 'contact',
        component: ContactComponent,
    },
    {
        path: 'blog',
        component: BlogComponent,
    },
    {
        path: 'portfolio',
        component: PortfolioComponent,
    },
    {
        path: 'about',
        component: AboutComponent,
    },
    {
        path: '',
        component: AboutComponent,
    },
];

@NgModule({
    imports: [
        RouterModule.forRoot(routes)
    ],
    exports: [
        RouterModule
    ],
    declarations: []
})
export class AppRoutingModule { }
